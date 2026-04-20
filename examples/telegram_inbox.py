#!/usr/bin/env python3
import json
import logging
import mimetypes
import os
import re
import unicodedata
from datetime import timezone
from pathlib import Path

from telegram import Update
from telegram.ext import ApplicationBuilder, ContextTypes, MessageHandler, filters

BOT_TOKEN = os.environ["TELEGRAM_BOT_TOKEN"]
INBOX_DIR = Path(os.environ.get("TELEGRAM_INBOX_DIR", "./.nest/in")).expanduser()
ALLOWED_USER_IDS = {
    int(x.strip())
    for x in os.environ.get("TELEGRAM_ALLOWED_USER_IDS", "").split(",")
    if x.strip()
}

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(name)s: %(message)s",
)
log = logging.getLogger("telegram_inbox")


def slugify(text: str, max_len: int = 60) -> str:
    text = (text or "").strip().replace("\n", " ")
    text = unicodedata.normalize("NFKD", text)
    text = text.encode("ascii", "ignore").decode("ascii")
    text = text.lower()
    text = re.sub(r"https?://\S+", "", text)
    text = re.sub(r"[^a-z0-9]+", "-", text).strip("-")
    return (text[:max_len].strip("-") or "item")


def pick_message_text(message) -> str:
    return (message.text or message.caption or "").strip()


def ensure_allowed(message) -> bool:
    if not ALLOWED_USER_IDS:
        return True
    user = message.from_user
    return bool(user and user.id in ALLOWED_USER_IDS)


def build_item_paths(message) -> tuple[Path, Path]:
    dt = message.date.astimezone(timezone.utc)
    stamp = dt.strftime("%Y-%m-%dT%H-%M-%SZ")
    base_text = pick_message_text(message)
    slug = slugify(base_text)
    final_name = f"{stamp}__{message.message_id}__{slug}"
    final_dir = INBOX_DIR / final_name
    staging_dir = INBOX_DIR / f"{final_name}.hatching"
    return staging_dir, final_dir


def detect_extension(filename: str | None, mime_type: str | None, fallback: str = "") -> str:
    if filename:
        ext = Path(filename).suffix
        if ext:
            return ext
    if mime_type:
        ext = mimetypes.guess_extension(mime_type)
        if ext:
            return ext
    return fallback


async def download_telegram_file(tg_file, dest: Path):
    dest.parent.mkdir(parents=True, exist_ok=True)
    await tg_file.download_to_drive(custom_path=str(dest))
    return dest


async def save_attachments(message, item_dir: Path) -> list[dict]:
    saved = []

    if message.photo:
        photo = message.photo[-1]
        tg_file = await photo.get_file()
        dest = item_dir / f"photo{detect_extension(None, 'image/jpeg', '.jpg')}"
        await download_telegram_file(tg_file, dest)
        saved.append({
            "kind": "photo",
            "filename": dest.name,
            "telegram_file_id": photo.file_id,
            "telegram_unique_file_id": photo.file_unique_id,
            "file_size": getattr(photo, "file_size", None),
        })

    if message.document:
        doc = message.document
        tg_file = await doc.get_file()
        original_name = doc.file_name or f"document{detect_extension(None, doc.mime_type)}"
        dest = item_dir / original_name
        await download_telegram_file(tg_file, dest)
        saved.append({
            "kind": "document",
            "filename": dest.name,
            "telegram_file_id": doc.file_id,
            "telegram_unique_file_id": doc.file_unique_id,
            "mime_type": doc.mime_type,
            "file_size": doc.file_size,
        })

    if message.audio:
        audio = message.audio
        tg_file = await audio.get_file()
        original_name = audio.file_name or f"audio{detect_extension(None, audio.mime_type, '.mp3')}"
        dest = item_dir / original_name
        await download_telegram_file(tg_file, dest)
        saved.append({
            "kind": "audio",
            "filename": dest.name,
            "telegram_file_id": audio.file_id,
            "telegram_unique_file_id": audio.file_unique_id,
            "mime_type": audio.mime_type,
            "duration": audio.duration,
            "file_size": audio.file_size,
            "title": getattr(audio, "title", None),
            "performer": getattr(audio, "performer", None),
        })

    if message.voice:
        voice = message.voice
        tg_file = await voice.get_file()
        ext = detect_extension(None, voice.mime_type, ".ogg")
        dest = item_dir / f"voice{ext}"
        await download_telegram_file(tg_file, dest)
        saved.append({
            "kind": "voice",
            "filename": dest.name,
            "telegram_file_id": voice.file_id,
            "telegram_unique_file_id": voice.file_unique_id,
            "mime_type": voice.mime_type,
            "duration": voice.duration,
            "file_size": voice.file_size,
        })

    if message.video:
        video = message.video
        tg_file = await video.get_file()
        ext = detect_extension(None, video.mime_type, ".mp4")
        dest = item_dir / f"video{ext}"
        await download_telegram_file(tg_file, dest)
        saved.append({
            "kind": "video",
            "filename": dest.name,
            "telegram_file_id": video.file_id,
            "telegram_unique_file_id": video.file_unique_id,
            "mime_type": video.mime_type,
            "duration": video.duration,
            "file_size": video.file_size,
            "width": video.width,
            "height": video.height,
        })

    if message.video_note:
        note = message.video_note
        tg_file = await note.get_file()
        dest = item_dir / "video-note.mp4"
        await download_telegram_file(tg_file, dest)
        saved.append({
            "kind": "video_note",
            "filename": dest.name,
            "telegram_file_id": note.file_id,
            "telegram_unique_file_id": note.file_unique_id,
            "duration": note.duration,
            "file_size": note.file_size,
            "length": note.length,
        })

    return saved


def extract_links(text: str) -> list[str]:
    if not text:
        return []
    return re.findall(r"https?://\S+", text)


async def handle_message(update: Update, context: ContextTypes.DEFAULT_TYPE):
    message = update.effective_message
    if not message:
        return

    if not ensure_allowed(message):
        log.warning("Rejected message from non-whitelisted user_id=%s", getattr(message.from_user, "id", None))
        return

    staging_dir, final_dir = build_item_paths(message)

    if staging_dir.exists() or final_dir.exists():
        log.warning("Target already exists for message %s: %s", message.message_id, final_dir)
        return

    staging_dir.mkdir(parents=True, exist_ok=False)

    try:
        message_text = pick_message_text(message)
        if message_text:
            (staging_dir / "message.txt").write_text(message_text, encoding="utf-8")

        attachments = await save_attachments(message, staging_dir)

        from_user = message.from_user
        chat = message.chat

        meta = {
            "schema_version": 1,
            "source": "telegram",
            "ingest_mode": "passive",
            "ingest_status": "stored",
            "staging_suffix": ".hatching",
            "message_file": "message.txt" if message_text else None,
            "stored_at_path": str(final_dir.resolve()),
            "message": {
                "message_id": message.message_id,
                "date_utc": message.date.astimezone(timezone.utc).isoformat(),
                "text_present": bool(message.text),
                "caption_present": bool(message.caption),
                "text_length": len(message_text),
                "links": extract_links(message_text),
            },
            "from": {
                "user_id": getattr(from_user, "id", None),
                "is_bot": getattr(from_user, "is_bot", None),
                "username": getattr(from_user, "username", None),
                "first_name": getattr(from_user, "first_name", None),
                "last_name": getattr(from_user, "last_name", None),
            },
            "chat": {
                "chat_id": getattr(chat, "id", None),
                "type": getattr(chat, "type", None),
                "title": getattr(chat, "title", None),
                "username": getattr(chat, "username", None),
            },
            "attachments": attachments,
        }

        (staging_dir / "meta.json").write_text(
            json.dumps(meta, ensure_ascii=False, indent=2),
            encoding="utf-8",
        )

        staging_dir.rename(final_dir)
        log.info("Stored message %s in %s", message.message_id, final_dir)

    except Exception:
        log.exception("Failed while storing message %s in %s", message.message_id, staging_dir)
        raise


async def post_init(app):
    INBOX_DIR.mkdir(parents=True, exist_ok=True)
    log.info("Inbox directory: %s", INBOX_DIR.resolve())
    if ALLOWED_USER_IDS:
        log.info("Whitelist enabled for %d user(s)", len(ALLOWED_USER_IDS))
    else:
        log.warning("No whitelist configured; all users can message this bot")


def main():
    app = (
        ApplicationBuilder()
        .token(BOT_TOKEN)
        .post_init(post_init)
        .build()
    )

    app.add_handler(
        MessageHandler(
            filters.ALL & ~filters.COMMAND,
            handle_message,
        )
    )

    app.run_polling(
        allowed_updates=Update.ALL_TYPES,
        drop_pending_updates=False,
    )


if __name__ == "__main__":
    main()
