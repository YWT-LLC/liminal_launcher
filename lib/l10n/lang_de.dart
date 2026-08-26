// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'lang.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class LangDe extends Lang {
  LangDe([String locale = 'de']) : super(locale);

  @override
  String aplSort(Object type) {
    return 'Sortieren: $type';
  }

  @override
  String get aplDate => 'Datum';

  @override
  String get aplName => 'Name';

  @override
  String get aplPublisher => 'Herausgeber';

  @override
  String get aplSize => 'Größe';

  @override
  String get aplAsc => 'Reihenfolge: aufsteigend';

  @override
  String get aplDsc => 'Reihenfolge: absteigend';

  @override
  String get clkTitle => 'Uhr';

  @override
  String get clkBackground => 'Hintergrund';

  @override
  String get clkBackgroundColor => 'Hintergrundfarbe';

  @override
  String get clkBackgroundShape => 'Hintergrundform';

  @override
  String get clkDate => 'Datum';

  @override
  String get clkDateColor => 'Datumsfarbe';

  @override
  String get clkDateStyle => 'Datumsstil';

  @override
  String get clkDateType => 'Datumstyp';

  @override
  String get clkCompact => 'Kompakt';

  @override
  String get clkLong => 'Lang';

  @override
  String get clkMedium => 'Mittel';

  @override
  String get clkShort => 'Kurz';

  @override
  String get clkTime => 'Zeit';

  @override
  String get clkTimeBool => 'Zeit anzeigen';

  @override
  String get clkTimeColor => 'Zeitfarbe';

  @override
  String get clkTimeStyle => 'Zeitstil';

  @override
  String dbsTileType(Object type) {
    return '$type-Kachel';
  }

  @override
  String get dbsChangeApp => 'Lange drücken, um die App zu ändern.';

  @override
  String get dbsApp => 'Liminal App';

  @override
  String get dbsFolder => 'Liminal Ordner';

  @override
  String get dbsLabelType => 'Label-Typ';

  @override
  String get dbsInitials => 'Initialen';

  @override
  String get dbsFull => 'Vollständig';

  @override
  String get dbsWingding => 'Wingding';

  @override
  String get dbsElevatedButton => 'Hervorgehobener Button';

  @override
  String get dbsShowIcon => 'Symbol anzeigen';

  @override
  String get dbsElevatedStyle => 'Hervorgehobener Stil';

  @override
  String get dpsPageSettings => 'Seiteneinstellungen';

  @override
  String get dpsWallpaper => 'Hintergrundbild';

  @override
  String get dpsUseOS => 'Vom System übernehmen';

  @override
  String get dpsAlign => 'Ausrichten';

  @override
  String get dpsListAlign => 'Listenausrichtung';

  @override
  String get dpsAlignHint =>
      'Liminal Launcher-Symbol für Ausrichtungsvorschau verwendet';

  @override
  String get dpsHideStatus => 'Statusleiste ausblenden';

  @override
  String get dpsPages => 'Startbildschirm-Seiten';

  @override
  String get evtAppIcon => 'App-Symbol verwenden';

  @override
  String get evtCalendar => 'Kalender';

  @override
  String get evtClear => 'Lange drücken zum Löschen';

  @override
  String get evtCreate => 'Erstellen';

  @override
  String get evtNewEvent => 'Neues Ereignis';

  @override
  String get evtNewTask => 'Neue Aufgabe';

  @override
  String get evtNoCalendar =>
      'Es wurde keine Standard-Kalender-App gefunden.\nWas soll ich tun?\n\n\'Aufgabe\' ist hier nur eine Teilen-Funktion. Du wählst eine Standard-App zum Teilen aus.\nWir empfehlen eine Aufgaben-App, aber sie ist nicht zwingend erforderlich.\nErgebnisse können variieren.';

  @override
  String get evtShare =>
      '\'Aufgabe\' ist hier nur eine Teilen-Funktion.\nWähle unten eine Ziel-App aus.\n\nWir empfehlen eine Aufgaben-App, aber sie ist nicht zwingend erforderlich. Ergebnisse können variieren.';

  @override
  String get evtShareDest => 'Teilen-Ziel wird ausgewählt';

  @override
  String get evtTask => 'Aufgabe';

  @override
  String get evtUseTasks => 'Zu Aufgaben wechseln';

  @override
  String fldAddTo(Object name) {
    return 'Zu $name hinzufügen';
  }

  @override
  String get fldAppearance => 'Aussehen';

  @override
  String get fldApps => 'Apps';

  @override
  String get gAdd => 'Hinzufügen';

  @override
  String get gAdded => 'Hinzugefügt';

  @override
  String get gClear => 'Löschen';

  @override
  String get gDefault => 'Standard';

  @override
  String get gDupe => 'Duplizieren';

  @override
  String get gEdit => 'Bearbeiten';

  @override
  String get gEdits => 'Änderungen';

  @override
  String get gEditDefaults => 'Standardwerte bearbeiten';

  @override
  String get gKey => 'Schlüssel';

  @override
  String get gPreview => 'Vorschau';

  @override
  String get gResize => 'Größe ändern';

  @override
  String get gReset => 'Zurücksetzen';

  @override
  String get gButton => 'Button';

  @override
  String get gTile => 'Kachel';

  @override
  String get gWideTiles => 'Breite Kacheln';

  @override
  String get gSearch => 'Suchen';

  @override
  String get gSearchBar => 'Suchleiste';

  @override
  String get gEnd => 'Ende';

  @override
  String get gCenter => 'Mitte';

  @override
  String get gStart => 'Start';

  @override
  String get gBottom => 'Unten';

  @override
  String get gLeft => 'Links';

  @override
  String get gRight => 'Rechts';

  @override
  String get gTop => 'Oben';

  @override
  String get gHorizontal => 'Horizontal';

  @override
  String get gVertical => 'Vertikal';

  @override
  String get gHidden => 'Versteckt';

  @override
  String get gShared => 'Geteilt';

  @override
  String get gShown => 'Angezeigt';

  @override
  String get gOutlined => 'Umrandet';

  @override
  String get gSolid => 'Ausgefüllt';

  @override
  String get gFailed => 'Fehlgeschlagen';

  @override
  String get gInvalid => 'Ungültig';

  @override
  String get gNoEmpty => 'Darf nicht leer sein';

  @override
  String get gNothing => 'Nichts';

  @override
  String get gRemoving => 'Wird entfernt';

  @override
  String get gSelfDestruct => 'Selbstzerstörung';

  @override
  String get gMachineTranslated =>
      'Alles ist maschinell übersetzt. Wenn du einen Fehler siehst, reiche bitte eine Korrektur ein!\n';

  @override
  String get gTranslations => 'Übersetzungs-Link.';

  @override
  String get gFix => 'Korrigieren...';

  @override
  String get gLauncherEntries => 'Launcher-Einträge';

  @override
  String get gSettingsEntries => 'Einstellungs-Einträge';

  @override
  String get gsAppList => 'App-Liste';

  @override
  String get gsLinkedList => 'Verknüpfte Startbildschirm-Listen';

  @override
  String get gsThemedHome =>
      'Die Startbildschirm-Liste kann auch themenbezogen sein!';

  @override
  String get gsNoBothHome =>
      'Hinweis: Die Startseiten aktualisieren nicht beide Systeme gleichzeitig (';

  @override
  String get gsIndependent =>
      ').\nDie Listen sind völlig unabhängig voneinander.';

  @override
  String get gsRelinked =>
      'Wenn sie (wieder) verknüpft werden, wirst du gefragt, welche Version du behalten möchtest.';

  @override
  String get gsKeepWhich => 'Welches Layout behalten?';

  @override
  String get gsAutoSearch => 'Automatische Suche in der App-Liste';

  @override
  String get gsHomeRipple => 'Startbildschirm-Wellen-Animation';

  @override
  String get gsListRipple => 'Listen-Wellen-Animation';

  @override
  String get gsQuickLaunch => 'Schnellstart';

  @override
  String get gsQLDescription =>
      'Auf dem Startbildschirm nach links/rechts wischen (außer beim Bearbeiten), um die ausgewählte App zu öffnen.\nLange drücken, um deine Auswahl zu löschen.';

  @override
  String gsSwipe(Object direction) {
    return 'Nach $direction wischen';
  }

  @override
  String gsSwipeDesc(Object direction) {
    return 'Wähle eine Schnellzugriffs-App, die geöffnet wird, wenn du auf dem Startbildschirm nach $direction wischst.';
  }

  @override
  String gsSwipeHint(Object direction) {
    return 'Wähle die App, die sich beim Wischen nach $direction öffnet';
  }

  @override
  String gsSwipeLabel(Object direction) {
    return 'Auswahl für das Wischen nach $direction';
  }

  @override
  String get gsSecurity => 'Sicherheit';

  @override
  String get gsAuthToEdit =>
      'Authentifizieren, um Listen/Einstellungen zu bearbeiten';

  @override
  String get gsAuthForHidden => 'Authentifizieren, um versteckte Apps zu sehen';

  @override
  String get gsAuthTimeout => 'Authentifizierungs-Timeout (Minuten)';

  @override
  String get gsPositiveOnly => 'Nur positive ganze Zahlen';

  @override
  String get hsHome => 'Start';

  @override
  String get hsHomeHint => 'Start. Lange drücken zum Bearbeiten.';

  @override
  String get hsWelcome => 'Willkommen beim Liminal Launcher';

  @override
  String get hsDescription =>
      'Er ist auf Minimalismus ausgerichtet,\nbietet aber grenzenlose Anpassungsmöglichkeiten.';

  @override
  String get hsUserSettings =>
      'Als allgemeine Regel gilt: Das Aussehen von Liminal kann je nach Theme-Modus völlig unterschiedlich sein!\n\nIn den entsprechenden Einstellungen siehst du ein umschaltbares Symbol, das anzeigt, ob du gerade das dunkle ';

  @override
  String get hsLight => ', das helle ';

  @override
  String get hsBoth => ', oder beide ';

  @override
  String get hsThemes => ' Themes bearbeitest.';

  @override
  String get hsGetStarted =>
      'Halte den Startbildschirm lange gedrückt, um loszulegen.\nVielen Dank und viel Spaß!';

  @override
  String get hsOneMore => 'Noch eine Sache...';

  @override
  String get hsFree =>
      'Diese Version stammt nicht aus dem Play Store, daher sollte sie kostenlos gewesen sein.\nSei versichert, die kostenlose Version von Liminal wird immer mit der Google Play-Version identisch sein.\n\nWenn du die Entwicklung von Liminal oder weiteren coolen Programmen unterstützen möchtest, ziehe bitte in Erwägung, etwas ';

  @override
  String get hsContribute => 'beizutragen';

  @override
  String get hsContributeHint =>
      'Öffnet einen Link zu Unterstützungsmöglichkeiten';

  @override
  String get hsPopUp =>
      '.\n\nDies ist das einzige Pop-up, das kein Tutorial ist, und es wird in dieser Installation nur einmal angezeigt.';

  @override
  String get hsOkay => 'Okay';

  @override
  String get hsApp => 'App';

  @override
  String get hsFolder => 'Ordner';

  @override
  String get hsLane => 'Spur';

  @override
  String get hsSpacer => 'Abstandshalter';

  @override
  String get hsWidget => 'Widget';

  @override
  String get hsScreenLanes => ' Spuren auf dem Bildschirm.';

  @override
  String get hsWithCurr => 'Mit deiner aktuellen...\n\nSymbolgröße (';

  @override
  String get hsPadding => '),\nInnenabstand (';

  @override
  String get hsSpacing => '),\n& Außenabstand (';

  @override
  String get hsCanFit => '...Werten passen bis zu ';

  @override
  String get hsWithMin => ' Mit den Minimalwerten passen bis zu ';

  @override
  String get hsLanes => ' Spuren.';

  @override
  String get hsEditAuth => 'Authentifizieren, um den Launcher zu bearbeiten';

  @override
  String get hsHiddenAuth => 'Authentifizieren, um versteckte Apps zu sehen';

  @override
  String get mcIconButton => 'Größe der Symbol-Schaltfläche';

  @override
  String get mcBanish => 'Verbannen';

  @override
  String get mcDelete => 'Löschen';

  @override
  String get mcDone => 'Fertig';

  @override
  String get mcHide => 'Ausblenden';

  @override
  String get mcInfo => 'Info';

  @override
  String get mcReposition => 'Neu positionieren';

  @override
  String get mcMove => 'Verschieben';

  @override
  String get mcMoveDown => 'Nach unten verschieben';

  @override
  String get mcMoveLeft => 'Nach links verschieben';

  @override
  String get mcMoveRight => 'Nach rechts verschieben';

  @override
  String get mcMoveUp => 'Nach oben verschieben';

  @override
  String get mcRemove => 'Entfernen';

  @override
  String get mcSave => 'Speichern';

  @override
  String get mcShow => 'Anzeigen';

  @override
  String get mcUninstall => 'Deinstallieren';

  @override
  String get mltLaneConfig => 'Multi-Spur-Konfiguration';

  @override
  String get mltPagesEnabled =>
      'Wenn Seiten aktiviert sind, verhalten sich die Spuren wie Seiten bei einem herkömmlichen Launcher.\n';

  @override
  String get mltPagesDisabled =>
      'Wenn Seiten deaktiviert sind, teilen sich alle Spuren eine horizontale Scrollfunktion.\n';

  @override
  String get mltWideEnabled => 'Wenn breite Kacheln aktiviert sind...\n';

  @override
  String get mltWideWidth =>
      'nimmt jede Spur (mit einem Element) die Breite eines Bildschirms ein.\n';

  @override
  String get mltAnywhere =>
      'können Apps und Ordner überall in ihrem horizontalen Bereich aktiviert werden.\n';

  @override
  String get mltWideDisabled => 'Wenn breite Kacheln deaktiviert sind...\n';

  @override
  String get mltAutoWidth =>
      'werden die Spuren anhand ihres breitesten Elements & deiner Abstandseinstellungen dimensioniert.\n';

  @override
  String get mltOnlyButton =>
      'können Apps und Ordner nur über ihre(n) Button(s) aktiviert werden.\n';

  @override
  String get pHiddenReminder =>
      'Wische beim Bearbeiten nach oben, um die Liste der versteckten Apps zu öffnen.';

  @override
  String get pReminder => 'Erinnerung';

  @override
  String pBanishApp(Object app) {
    return '$app verbannen?';
  }

  @override
  String pRemoveLane(Object lane) {
    return '$lane entfernen?';
  }

  @override
  String get pWantTo => 'Möchtest du...';

  @override
  String get pHideDarkToo => 'Auch für den dunklen Modus ausblenden?';

  @override
  String get pHideLightToo => 'Auch für den hellen Modus ausblenden?';

  @override
  String get pShowDarkToo => 'Auch für den dunklen Modus anzeigen?';

  @override
  String get pShowLightToo => 'Auch für den hellen Modus anzeigen?';

  @override
  String pWhatBanish(Object undo) {
    return 'Wenn du eine App verbannst, bleibt sie weiterhin installiert, wird aber in Liminal überhaupt nicht mehr angezeigt.\nVerbannte Apps können nur noch über die Systemeinstellungen oder über einen App-Link geöffnet werden.\n\nDas Verbannen ist nützlich für Dienstprogramm-Apps, die auch Zeit verschwenden. Zum Beispiel könntest du deinen Webbrowser verbannen.\nSo kannst du Online-Speisekarten nutzen, wenn du ausgehst, und das Doom-Scrolling reduzieren, wenn du zu Hause bleibst.\n\n$undo\n\nErinnerung: Das Verbannen dient nur der Benutzererfahrung, nicht der Sicherheit.\nBeispiel: Wenn eine App dauerhaften Standortzugriff hat, ändert das Verbannen nichts daran.';
  }

  @override
  String pUnBanish(Object app) {
    return 'Der einfachste Weg, $app wiederherzustellen/zu entbannen, besteht darin, sie über die Systemeinstellungen zu deinstallieren und dann neu zu installieren.';
  }

  @override
  String get srcCustom => 'Benutzerdefiniert';

  @override
  String get srcName => 'Name ';

  @override
  String get srcBase => 'Basis-Seite ';

  @override
  String get srcPath => 'Pfad ';

  @override
  String get srcParameter => 'Parameter ';

  @override
  String get srcNonEmpty => 'Ein nicht-leerer Name ist erforderlich.';

  @override
  String get srcPlayResponsibly =>
      'Liminal führt nur eine minimale Überprüfung dieser benutzerdefinierten Eingaben durch.\nNutzung auf eigene Gefahr.';

  @override
  String get srcSameName =>
      'Ein benutzerdefinierter Eintrag mit diesem Namen existiert bereits.\nBitte ändere den Namen und versuche es erneut.';

  @override
  String get thmSelector => 'Auswahl';

  @override
  String get thmToggle => 'Theme umschalten';

  @override
  String get timTitle => 'Timer';

  @override
  String get timHours => 'Stunden';

  @override
  String get timMins => 'Minuten';

  @override
  String get timSecs => 'Sekunden';

  @override
  String get timBadTime => 'Ungültige Zeit';

  @override
  String get timQuick => 'Schnelle Zeiten';

  @override
  String get togTitle => 'Mediensteuerung';

  @override
  String get togFF => 'Schneller Vorlauf';

  @override
  String get togNext => 'Weiter';

  @override
  String get togPlayPause => 'Wiedergabe/Pause';

  @override
  String get togPrevious => 'Zurück';

  @override
  String get togRewind => 'Zurückspulen';

  @override
  String get togFFTog => 'Vor-/Zurückspulen';

  @override
  String get togSkipTog => 'Überspringen/Zurück';

  @override
  String get togSomePlayers =>
      'Hinweis:\nDiese Tasten funktionieren nur, wenn der aktive Player sie unterstützt. Einige Musik-Player verfügen beispielsweise nicht über Vor-/Zurückspulen.';
}
