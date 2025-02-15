import mobase
from PyQt6.QtCore import QFileInfo

from ..basic_game import BasicGame
from ..basic_features import BasicModDataChecker, GlobPatterns
from ..basic_features.utils import is_directory

class KotorModDataChecker(BasicModDataChecker):
    """
    A mod data checking feature for KOTOR2 that validates the mod folder structure.
    
    Instead of looking for specific folder names, this checker returns VALID
    if it finds any subdirectory inside the mod folder.
    """
    def __init__(self):
        # We supply an empty GlobPatterns instance since we override dataLooksValid.
        super().__init__(GlobPatterns(valid=[]))

    def dataLooksValid(self, filetree: mobase.IFileTree) -> mobase.ModDataChecker.CheckReturn:
        mobase.logInfo("KotorModDataChecker: Checking mod data structure for any directory...")
        for entry in filetree:
            # Use the helper function to determine if the entry is a directory.
            if is_directory(entry):
                mobase.logInfo(f"KotorModDataChecker: Found directory '{entry.name()}'")
                return mobase.ModDataChecker.VALID
        mobase.logInfo("KotorModDataChecker: No directories found in mod data.")
        return mobase.ModDataChecker.INVALID

    def fix(self, filetree: mobase.IFileTree) -> mobase.IFileTree:
        mobase.logInfo("KotorModDataChecker: Automatic fix not implemented.")
        return filetree


class StarWarsKotor2Game(BasicGame):
    """
    A MO2 game plugin for STAR WARS Knights of the Old Republic II The Sith Lords
    that includes a mod data checking feature.
    """
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
    GameDataPath = ""  # Specify if a separate data path is used

    def executables(self) -> list[mobase.ExecutableInfo]:
        return [
            mobase.ExecutableInfo(
                "STAR WARS Knights of the Old Republic II The Sith Lords",
                QFileInfo(self.gameDirectory().absoluteFilePath(self.binaryName()))
            )
        ]

    def initialize(self):
        """
        Called during plugin initialization.
        
        Retrieves MO2’s game features interface and registers the custom mod data checker.
        """
        # Call the parent initialization.
        super().initialize()

        organizer = self.organizer()
        if not organizer:
            mobase.logError("Organizer interface is unavailable; cannot register mod data checker.")
            return

        game_features = organizer.gameFeatures()
        if not game_features:
            mobase.logError("Game features interface is unavailable.")
            return

        # Create and register the Kotor mod data checker.
        mod_data_checker = KotorModDataChecker()
        game_features.registerFeature(mod_data_checker, "KotorModDataChecker", [self.GameShortName], 100)
        mobase.logInfo("KotorModDataChecker registered for KOTOR2 successfully.")
