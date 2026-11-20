from pathlib import Path
from shutil import copy2

from PIL import Image, ImageChops, ImageDraw


ROOT = Path(__file__).resolve().parent
DOWNLOADS = Path(r"C:\Users\user\Downloads")
SEPARATED_DOUBLE = DOWNLOADS / "Asset Alfhabet" / "Dabel"
SEPARATED_ILLUSTRATED = DOWNLOADS / "Asset Alfhabet" / "Gambar"
SEPARATED_UPPERCASE = DOWNLOADS / "Asset Alfhabet" / "Kapital"
LETTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
ILLUSTRATED_FILES = {
	"A": "Apel.png", "B": "Bola.png", "C": "Cacing.png", "D": "Dino.png",
	"E": "Elang.png", "F": "Flaminggo.png", "G": "Gajah.png", "H": "Harimau.png",
	"I": "Ikan.png", "J": "Jeli.png", "K": "Kangguru.png", "L": "Landak.png",
	"M": "Mangga.png", "N": "Nanas.png", "O": "Obor.png", "P": "Panda.png",
	"Q": "Queen.png", "R": "Robot.png", "S": "Singa.png", "T": "Tikus.png",
	"U": "Ular.png", "V": "Vas.png", "W": "Wayang.png", "X": "Xilofon.png",
	"Y": "Yoyo.png", "Z": "Zebra.png",
}


def write_tile(source: Image.Image, center: tuple[int, int], size: tuple[int, int], destination: Path) -> None:
	"""Export one card with the sheet background removed at its corners.

	The card bounds below were measured from the outside outline of every card,
	so none of the letter, picture, label, or leaf decoration gets clipped.
	"""
	width, height = size
	left = center[0] - width // 2
	top = center[1] - height // 2
	tile = source.crop((left, top, left + width, top + height))
	mask = Image.new("L", tile.size, 0)
	ImageDraw.Draw(mask).rounded_rectangle((2, 2, width - 3, height - 3), radius=38, fill=255)
	tile.putalpha(ImageChops.multiply(tile.getchannel("A"), mask))
	tile.save(destination)


def export_grid(source_path: Path, destination: Path, centers: list[tuple[int, int]], size: tuple[int, int], lowercase: bool = False) -> None:
	destination.mkdir(parents=True, exist_ok=True)
	source = Image.open(source_path).convert("RGBA")
	for index, letter in enumerate(LETTERS):
		filename = letter.lower() if lowercase else letter
		write_tile(source, centers[index], size, destination / (filename + ".png"))


def export_separated_double(destination: Path) -> None:
	"""Use the hand-separated Aa tiles instead of recropping the old sprite sheet."""
	destination.mkdir(parents=True, exist_ok=True)
	for letter in LETTERS:
		source = SEPARATED_DOUBLE / (letter + letter.lower() + ".png")
		copy2(source, destination / (letter + ".png"))


def export_separated_illustrated(destination: Path) -> None:
	"""Copy the supplied A-Z picture cards without resampling or crop loss."""
	destination.mkdir(parents=True, exist_ok=True)
	for letter, filename in ILLUSTRATED_FILES.items():
		copy2(SEPARATED_ILLUSTRATED / filename, destination / (letter + ".png"))


def export_separated_uppercase(destination: Path) -> None:
	"""Use the supplied individual capital-letter cards for Level 3."""
	destination.mkdir(parents=True, exist_ok=True)
	for letter in LETTERS:
		copy2(SEPARATED_UPPERCASE / (letter + ".png"), destination / (letter + ".png"))


def main() -> None:
	# Level 1 / 2 / 4: use the already-separated Aa PNGs supplied for the game.
	export_separated_double(ROOT / "assets" / "ui" / "alphabet" / "plain")

	# Level 1 detail screen: use the hand-separated picture cards, including
	# their full picture and word label.
	export_separated_illustrated(ROOT / "assets" / "ui" / "alphabet" / "illustrated")

	# Level 3 capital row: use the individually separated cards.
	export_separated_uppercase(ROOT / "assets" / "ui" / "alphabet" / "uppercase")

	lower_columns = [206, 431, 652, 882, 1109, 1335]
	lower_centers = [(lower_columns[index % 6], [123, 341, 557, 719][index // 6]) for index in range(24)]
	lower_centers += [(650, 906), (880, 906)]
	export_grid(DOWNLOADS / "Asset Alfhabet" / "T Kapital" / "Pastel Kawaii Lowercase Alphabet Tiles.png", ROOT / "assets" / "ui" / "alphabet" / "lowercase", lower_centers, (220, 200), True)


if __name__ == "__main__":
	main()
