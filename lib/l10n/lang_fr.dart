// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'lang.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class LangFr extends Lang {
  LangFr([String locale = 'fr']) : super(locale);

  @override
  String aplSort(Object type) {
    return 'Trier : $type';
  }

  @override
  String get aplDate => 'Date';

  @override
  String get aplName => 'Nom';

  @override
  String get aplPublisher => 'Éditeur';

  @override
  String get aplSize => 'Taille';

  @override
  String get aplAsc => 'Ordre : croissant';

  @override
  String get aplDsc => 'Ordre : décroissant';

  @override
  String get clkTitle => 'Horloge';

  @override
  String get clkBackground => 'Arrière-plan';

  @override
  String get clkBackgroundColor => 'Couleur d\'arrière-plan';

  @override
  String get clkBackgroundShape => 'Forme d\'arrière-plan';

  @override
  String get clkDate => 'Date';

  @override
  String get clkDateColor => 'Couleur de la date';

  @override
  String get clkDateStyle => 'Style de la date';

  @override
  String get clkDateType => 'Format de la date';

  @override
  String get clkCompact => 'Compact';

  @override
  String get clkLong => 'Long';

  @override
  String get clkMedium => 'Moyen';

  @override
  String get clkShort => 'Court';

  @override
  String get clkTime => 'Heure';

  @override
  String get clkTimeBool => 'Afficher l\'heure';

  @override
  String get clkTimeColor => 'Couleur de l\'heure';

  @override
  String get clkTimeStyle => 'Style de l\'heure';

  @override
  String dbsTileType(Object type) {
    return 'Tuile $type';
  }

  @override
  String get dbsChangeApp => 'Appui long pour changer d\'application.';

  @override
  String get dbsApp => 'Application Liminal';

  @override
  String get dbsFolder => 'Dossier Liminal';

  @override
  String get dbsLabelType => 'Type d\'étiquette';

  @override
  String get dbsInitials => 'Initiales';

  @override
  String get dbsFull => 'Complet';

  @override
  String get dbsWingding => 'Wingding';

  @override
  String get dbsElevatedButton => 'Bouton en relief';

  @override
  String get dbsShowIcon => 'Afficher l\'icône';

  @override
  String get dbsElevatedStyle => 'Style en relief';

  @override
  String get dpsPageSettings => 'Paramètres de la page';

  @override
  String get dpsWallpaper => 'Fond d\'écran';

  @override
  String get dpsUseOS => 'Utiliser l\'OS';

  @override
  String get dpsAlign => 'Aligner';

  @override
  String get dpsListAlign => 'Alignement de la liste';

  @override
  String get dpsAlignHint =>
      'L\'icône de Liminal Launcher est utilisée pour l\'aperçu de l\'alignement';

  @override
  String get dpsHideStatus => 'Masquer la barre d\'état';

  @override
  String get dpsPages => 'Pages de l\'écran d\'accueil';

  @override
  String get evtAppIcon => 'Utiliser l\'icône de l\'application';

  @override
  String get evtCalendar => 'Calendrier';

  @override
  String get evtClear => 'Appui long pour effacer';

  @override
  String get evtCreate => 'Créer';

  @override
  String get evtNewEvent => 'Nouvel événement';

  @override
  String get evtNewTask => 'Nouvelle tâche';

  @override
  String get evtNoCalendar =>
      'Impossible de trouver une application de calendrier par défaut.\nQue dois-je faire ?\n\n\'Tâche\' est simplement un partage en arrière-plan. Vous choisirez une application par défaut avec laquelle partager.\nNous recommandons d\'utiliser une application de tâches, mais ce n\'est pas obligatoire.\nLes résultats peuvent varier.';

  @override
  String get evtShare =>
      '\'Tâche\' est simplement un partage en arrière-plan.\nChoisissez une application de destination ci-dessous.\n\nNous recommandons d\'utiliser une application de tâches, mais ce n\'est pas obligatoire. Les résultats peuvent varier.';

  @override
  String get evtShareDest => 'Sélection de la destination de partage';

  @override
  String get evtTask => 'Tâche';

  @override
  String get evtUseTasks => 'Passer aux tâches';

  @override
  String fldAddTo(Object name) {
    return 'Ajouter à $name';
  }

  @override
  String get fldAppearance => 'Apparence';

  @override
  String get fldApps => 'Applications';

  @override
  String get gAdd => 'Ajouter';

  @override
  String get gAdded => 'Ajouté';

  @override
  String get gClear => 'Effacer';

  @override
  String get gDefault => 'Par défaut';

  @override
  String get gDupe => 'Dupliquer';

  @override
  String get gEdit => 'Modifier';

  @override
  String get gEdits => 'Modifications';

  @override
  String get gEditDefaults => 'Modifier les paramètres par défaut';

  @override
  String get gKey => 'Clé';

  @override
  String get gPreview => 'Aperçu';

  @override
  String get gResize => 'Redimensionner';

  @override
  String get gReset => 'Réinitialiser';

  @override
  String get gButton => 'Bouton';

  @override
  String get gTile => 'Tuile';

  @override
  String get gWideTiles => 'Tuiles larges';

  @override
  String get gSearch => 'Rechercher';

  @override
  String get gSearchBar => 'Barre de recherche';

  @override
  String get gEnd => 'Fin';

  @override
  String get gCenter => 'Centre';

  @override
  String get gStart => 'Début';

  @override
  String get gBottom => 'Bas';

  @override
  String get gLeft => 'Gauche';

  @override
  String get gRight => 'Droite';

  @override
  String get gTop => 'Haut';

  @override
  String get gHorizontal => 'Horizontal';

  @override
  String get gVertical => 'Vertical';

  @override
  String get gHidden => 'Masqué';

  @override
  String get gShared => 'Partagé';

  @override
  String get gShown => 'Affiché';

  @override
  String get gOutlined => 'Contour';

  @override
  String get gSolid => 'Plein';

  @override
  String get gFailed => 'Échec';

  @override
  String get gInvalid => 'Invalide';

  @override
  String get gNoEmpty => 'Ne peut pas être vide';

  @override
  String get gNothing => 'Rien';

  @override
  String gRemoving(Object app) {
    return 'Supprimer $app';
  }

  @override
  String get gSelfDestruct => 'Autodestruction';

  @override
  String get gMachineTranslated =>
      'Tout est traduit par une machine. Si vous voyez une erreur, merci de proposer une correction !\n';

  @override
  String get gTranslations => 'Lien vers les traductions.';

  @override
  String get gFix => 'Corriger...';

  @override
  String get gLauncherEntries => 'Entrées du lanceur';

  @override
  String get gSettingsEntries => 'Entrées des paramètres';

  @override
  String get gsAppList => 'Liste des applications';

  @override
  String get gsLinkedList => 'Listes d\'accueil liées';

  @override
  String get gsThemedHome =>
      'La liste d\'accueil peut aussi être basée sur le thème !';

  @override
  String get gsNoBothHome =>
      'Note : les pages d\'accueil n\'ont pas de système de mise à jour pour les deux (';

  @override
  String get gsIndependent => ').\nLes listes seront totalement indépendantes.';

  @override
  String get gsRelinked =>
      'Si/quand elles seront reliées, il vous sera demandé quelle version conserver.';

  @override
  String get gsKeepWhich => 'Quelle disposition conserver ?';

  @override
  String get gsAutoSearch =>
      'Recherche automatique dans la liste des applications';

  @override
  String get gsHomeRipple => 'Animation d\'ondulation de l\'accueil';

  @override
  String get gsListRipple => 'Animation d\'ondulation de la liste';

  @override
  String get gsQuickLaunch => 'Lancement rapide';

  @override
  String get gsQLDescription =>
      'Balayez vers la gauche/droite sur l\'écran d\'accueil (sauf lors de la modification) pour ouvrir l\'application sélectionnée.\nAppui long pour effacer votre sélection.';

  @override
  String gsSwipe(Object direction) {
    return 'Balayage vers $direction';
  }

  @override
  String gsSwipeDesc(Object direction) {
    return 'Choisissez une application à accès rapide qui s\'ouvrira lorsque vous balayerez vers $direction sur l\'écran d\'accueil.';
  }

  @override
  String gsSwipeHint(Object direction) {
    return 'Choisissez l\'application qui s\'ouvre lors d\'un balayage vers $direction';
  }

  @override
  String gsSwipeLabel(Object direction) {
    return 'Sélection du balayage vers $direction';
  }

  @override
  String get gsSecurity => 'Sécurité';

  @override
  String get gsAuthToEdit =>
      'S\'authentifier pour modifier les listes/paramètres';

  @override
  String get gsAuthForHidden =>
      'S\'authentifier pour voir les applications masquées';

  @override
  String get gsAuthTimeout => 'Délai d\'authentification (mins)';

  @override
  String get gsPositiveOnly => 'Entiers positifs uniquement';

  @override
  String get hsHome => 'Accueil';

  @override
  String get hsHomeHint => 'Accueil. Appui long pour modifier.';

  @override
  String get hsWelcome => 'Bienvenue sur Liminal Launcher';

  @override
  String get hsDescription =>
      'Il est orienté vers le minimalisme,\nmais offre une personnalisation illimitée.';

  @override
  String get hsUserSettings =>
      'En règle générale : l\'apparence de Liminal peut être complètement séparée en fonction du mode de thème !\n\nDans les paramètres correspondants, vous verrez une icône basculable qui indique si vous modifiez le thème sombre ';

  @override
  String get hsLight => ', clair ';

  @override
  String get hsBoth => ', ou les deux ';

  @override
  String get hsThemes => ' thèmes.';

  @override
  String get hsGetStarted =>
      'Faites un appui long sur l\'écran d\'accueil pour commencer.\nMerci, et profitez bien !';

  @override
  String get hsOneMore => 'Encore une chose...';

  @override
  String get hsFree =>
      'Cette version ne provient pas du Play Store, elle devrait donc être gratuite.\nRassurez-vous, la version gratuite de Liminal sera toujours identique à celle de Google Play.\n\nSi vous souhaitez soutenir le développement de Liminal, ou la création d\'autres logiciels sympas, pensez à ';

  @override
  String get hsContribute => 'contribuer';

  @override
  String get hsContributeHint =>
      'Ouvrir un lien vers les options de contribution';

  @override
  String get hsPopUp =>
      '.\n\nCeci est la seule fenêtre contextuelle hors tutoriel, et sa seule apparition durant cette installation.';

  @override
  String get hsOkay => 'D\'accord';

  @override
  String get hsApp => 'Application';

  @override
  String get hsFolder => 'Dossier';

  @override
  String get hsLane => 'Ligne';

  @override
  String get hsSpacer => 'Espacement';

  @override
  String get hsWidget => 'Widget';

  @override
  String get hsScreenLanes => ' lignes à l\'écran.';

  @override
  String get hsWithCurr => 'Avec votre actuelle...\n\ntaille d\'icône (';

  @override
  String get hsPadding => '),\nmarge (';

  @override
  String get hsSpacing => '),\net espacement (';

  @override
  String get hsCanFit => '...vous pouvez faire tenir jusqu\'à ';

  @override
  String get hsWithMin =>
      ' Avec les valeurs minimales, vous pouvez faire tenir jusqu\'à ';

  @override
  String get hsLanes => ' lignes.';

  @override
  String get hsEditAuth => 'S\'authentifier pour modifier le lanceur';

  @override
  String get hsHiddenAuth =>
      'S\'authentifier pour voir les applications masquées';

  @override
  String get mcIconButton => 'Taille du bouton de l\'icône';

  @override
  String get mcBanish => 'Bannir';

  @override
  String get mcDelete => 'Supprimer';

  @override
  String get mcDone => 'Terminé';

  @override
  String get mcHide => 'Masquer';

  @override
  String get mcInfo => 'Infos';

  @override
  String get mcReposition => 'Repositionner';

  @override
  String get mcMove => 'Déplacer';

  @override
  String get mcMoveDown => 'Déplacer vers le bas';

  @override
  String get mcMoveLeft => 'Déplacer vers la gauche';

  @override
  String get mcMoveRight => 'Déplacer vers la droite';

  @override
  String get mcMoveUp => 'Déplacer vers le haut';

  @override
  String get mcRemove => 'Retirer';

  @override
  String get mcSave => 'Enregistrer';

  @override
  String get mcShow => 'Afficher';

  @override
  String get mcUninstall => 'Désinstaller';

  @override
  String get mltLaneConfig => 'Configuration multi-lignes';

  @override
  String get mltPagesEnabled =>
      'Avec les pages activées, les lignes se comportent comme les pages d\'un lanceur traditionnel.\n';

  @override
  String get mltPagesDisabled =>
      'Avec les pages désactivées, toutes les lignes partagent un défilement horizontal unique.\n';

  @override
  String get mltWideEnabled => 'Avec les tuiles larges activées...\n';

  @override
  String get mltWideWidth =>
      'chaque ligne (contenant un élément) aura la largeur d\'un écran.\n';

  @override
  String get mltAnywhere =>
      'les applications et les dossiers peuvent/seront activés n\'importe où dans leur espace horizontal.\n';

  @override
  String get mltWideDisabled => 'Avec les tuiles larges désactivées...\n';

  @override
  String get mltAutoWidth =>
      'les lignes seront dimensionnées en fonction de leur élément le plus large et de vos paramètres d\'espacement.\n';

  @override
  String get mltOnlyButton =>
      'les applications et dossiers peuvent/seront activés uniquement par leur(s) bouton(s).\n';

  @override
  String get pHiddenReminder =>
      'Balayez vers le haut lors de la modification pour ouvrir la liste des applications masquées.';

  @override
  String get pReminder => 'Rappel';

  @override
  String pBanishApp(Object app) {
    return 'Bannir $app ?';
  }

  @override
  String pRemoveLane(Object lane) {
    return 'Retirer $lane ?';
  }

  @override
  String get pWantTo => 'Voulez-vous...';

  @override
  String get pHideDarkToo => 'Masquer également pour le mode sombre ?';

  @override
  String get pHideLightToo => 'Masquer également pour le mode clair ?';

  @override
  String get pShowDarkToo => 'Afficher également pour le mode sombre ?';

  @override
  String get pShowLightToo => 'Afficher également pour le mode clair ?';

  @override
  String pWhatBanish(Object undo) {
    return 'Lorsque vous bannissez une application, elle reste installée mais n\'apparaît plus du tout dans Liminal.\nLes applications bannies ne peuvent être ouvertes que depuis les paramètres du système, ou via un lien d\'application.\n\nLe bannissement est utile pour les applications utilitaires qui font aussi perdre du temps. Par exemple, vous voudrez peut-être bannir votre/vos navigateur(s) web.\nAinsi, vous pourrez utiliser des menus en ligne lorsque vous sortez, et réduire le \'doom scrolling\' lorsque vous restez chez vous.\n\n$undo\n\nRappel : le bannissement n\'est que pour l\'expérience utilisateur, pas pour la sécurité.\nPar exemple : si une application a l\'autorisation d\'accéder à la localisation en permanence, le fait de la bannir ne changera pas cela.';
  }

  @override
  String pUnBanish(Object app) {
    return 'Le moyen le plus simple de restaurer/annuler le bannissement de $app est de la désinstaller depuis les paramètres du système, puis de la réinstaller.';
  }

  @override
  String get srcCustom => 'Personnalisé';

  @override
  String get srcName => 'Nom ';

  @override
  String get srcBase => 'Site de base ';

  @override
  String get srcPath => 'Chemin ';

  @override
  String get srcParameter => 'Paramètre ';

  @override
  String get srcNonEmpty => 'Un nom non vide est requis.';

  @override
  String get srcPlayResponsibly =>
      'Liminal effectue une validation minimale de ces entrées personnalisées.\nÀ utiliser à vos propres risques.';

  @override
  String get srcSameName =>
      'Une entrée personnalisée avec ce nom existe déjà.\nVeuillez modifier le nom et réessayer.';

  @override
  String get thmSelector => 'sélecteur';

  @override
  String get thmToggle => 'Basculer le thème';

  @override
  String get timTitle => 'Minuteur';

  @override
  String get timHours => 'Heures';

  @override
  String get timMins => 'Minutes';

  @override
  String get timSecs => 'Secondes';

  @override
  String get timBadTime => 'Temps invalide';

  @override
  String get timQuick => 'Temps rapides';

  @override
  String get togTitle => 'Contrôles multimédias';

  @override
  String get togFF => 'Avance rapide';

  @override
  String get togNext => 'Suivant';

  @override
  String get togPlayPause => 'Lecture/Pause';

  @override
  String get togPrevious => 'Précédent';

  @override
  String get togRewind => 'Retour rapide';

  @override
  String get togFFTog => 'Avance/Retour rapide';

  @override
  String get togSkipTog => 'Suivant/Précédent';

  @override
  String get togSomePlayers =>
      'Note :\nCes boutons ne fonctionnent que si le lecteur actif les prend en charge. Certains lecteurs de musique n\'ont pas l\'Avance/Retour rapide, par exemple.';
}
