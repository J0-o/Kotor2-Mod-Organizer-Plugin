import mobase
from PyQt6.QtCore import QFileInfo

from ..basic_game import BasicGame


class StarWarsKotor2Game(BasicGame):  # Updated class name for clarity
    Name = "STAR WARS Knights of the Old Republic II The Sith Lords"
    Author = "J"
    Version = "1.0.0"

    GameName = "STAR WARS Knights of the Old Republic II The Sith Lords"
    GameShortName = "kotor2"
    GameNexusName = "kotor2"
    GameNexusId = 198
    GameSteamId = 208580
    GameGogId = 1421404581
    GameBinary = "swkotor2.exe"
    GameDataPath = ""  # Specify if a relevant data path exists

    def executables(self) -> list[mobase.ExecutableInfo]:
        return [
            mobase.ExecutableInfo(
                "STAR WARS Knights of the Old Republic II The Sith Lords",
                QFileInfo(self.gameDirectory().absoluteFilePath(self.binaryName())),
            )
        ]

