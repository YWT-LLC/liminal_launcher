// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'lang.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class LangEs extends Lang {
  LangEs([String locale = 'es']) : super(locale);

  @override
  String aplSort(Object type) {
    return 'Ordenar: $type';
  }

  @override
  String get aplDate => 'Fecha';

  @override
  String get aplName => 'Nombre';

  @override
  String get aplPublisher => 'Editor';

  @override
  String get aplSize => 'Tamaño';

  @override
  String get aplAsc => 'Orden: ascendente';

  @override
  String get aplDsc => 'Orden: descendente';

  @override
  String get clkTitle => 'Reloj';

  @override
  String get clkBackground => 'Fondo';

  @override
  String get clkBackgroundColor => 'Color de fondo';

  @override
  String get clkBackgroundShape => 'Forma del fondo';

  @override
  String get clkDate => 'Fecha';

  @override
  String get clkDateColor => 'Color de la fecha';

  @override
  String get clkDateStyle => 'Estilo de la fecha';

  @override
  String get clkDateType => 'Tipo de fecha';

  @override
  String get clkCompact => 'Compacto';

  @override
  String get clkLong => 'Largo';

  @override
  String get clkMedium => 'Medio';

  @override
  String get clkShort => 'Corto';

  @override
  String get clkTime => 'Hora';

  @override
  String get clkTimeBool => 'Mostrar hora';

  @override
  String get clkTimeColor => 'Color de la hora';

  @override
  String get clkTimeStyle => 'Estilo de la hora';

  @override
  String dbsTileType(Object type) {
    return 'Mosaico $type';
  }

  @override
  String get dbsChangeApp => 'Mantén presionado para cambiar la aplicación.';

  @override
  String get dbsApp => 'Aplicación Liminal';

  @override
  String get dbsFolder => 'Carpeta Liminal';

  @override
  String get dbsLabelType => 'Tipo de etiqueta';

  @override
  String get dbsInitials => 'Iniciales';

  @override
  String get dbsFull => 'Completo';

  @override
  String get dbsWingding => 'Wingding';

  @override
  String get dbsElevatedButton => 'Botón elevado';

  @override
  String get dbsShowIcon => 'Mostrar ícono';

  @override
  String get dbsElevatedStyle => 'Estilo elevado';

  @override
  String get dpsPageSettings => 'Configuración de página';

  @override
  String get dpsWallpaper => 'Fondo de pantalla';

  @override
  String get dpsUseOS => 'Usar del SO';

  @override
  String get dpsAlign => 'Alinear';

  @override
  String get dpsListAlign => 'Alineación de la lista';

  @override
  String get dpsAlignHint =>
      'Ícono de Liminal Launcher usado para la vista previa de alineación';

  @override
  String get dpsHideStatus => 'Ocultar barra de estado';

  @override
  String get dpsPages => 'Páginas de la pantalla de inicio';

  @override
  String get evtAppIcon => 'Usar ícono de la aplicación';

  @override
  String get evtCalendar => 'Calendario';

  @override
  String get evtClear => 'Mantén presionado para borrar';

  @override
  String get evtCreate => 'Crear';

  @override
  String get evtNewEvent => 'Nuevo evento';

  @override
  String get evtNewTask => 'Nueva tarea';

  @override
  String get evtNoCalendar =>
      'No se puede encontrar una aplicación de calendario predeterminada.\n¿Qué debo hacer?\n\n\'Tarea\' es simplemente compartir por debajo. Elegirás una aplicación predeterminada para compartir.\nRecomendamos usar una aplicación de tareas, pero no es obligatorio.\nLos resultados pueden variar.';

  @override
  String get evtShare =>
      '\'Tarea\' es simplemente compartir por debajo.\nElige una aplicación de destino a continuación.\n\nRecomendamos usar una aplicación de tareas, pero no es obligatorio. Los resultados pueden variar.';

  @override
  String get evtShareDest => 'Seleccionando el destino para compartir';

  @override
  String get evtTask => 'Tarea';

  @override
  String get evtUseTasks => 'Cambiar a tareas';

  @override
  String fldAddTo(Object name) {
    return 'Agregar a $name';
  }

  @override
  String get fldAppearance => 'Apariencia';

  @override
  String get fldApps => 'Aplicaciones';

  @override
  String get gAdd => 'Agregar';

  @override
  String get gAdded => 'Agregado';

  @override
  String get gClear => 'Borrar';

  @override
  String get gDefault => 'Predeterminado';

  @override
  String get gDupe => 'Duplicar';

  @override
  String get gEdit => 'Editar';

  @override
  String get gEdits => 'Ediciones';

  @override
  String get gEditDefaults => 'Editar predeterminados';

  @override
  String get gKey => 'Clave';

  @override
  String get gPreview => 'Vista previa';

  @override
  String get gResize => 'Redimensionar';

  @override
  String get gReset => 'Restablecer';

  @override
  String get gButton => 'Botón';

  @override
  String get gTile => 'Mosaico';

  @override
  String get gWideTiles => 'Mosaicos anchos';

  @override
  String get gSearch => 'Buscar';

  @override
  String get gSearchBar => 'Barra de búsqueda';

  @override
  String get gEnd => 'Fin';

  @override
  String get gCenter => 'Centro';

  @override
  String get gStart => 'Inicio';

  @override
  String get gBottom => 'Abajo';

  @override
  String get gLeft => 'Izquierda';

  @override
  String get gRight => 'Derecha';

  @override
  String get gTop => 'Arriba';

  @override
  String get gHorizontal => 'Horizontal';

  @override
  String get gVertical => 'Vertical';

  @override
  String get gHidden => 'Oculto';

  @override
  String get gShared => 'Compartido';

  @override
  String get gShown => 'Mostrado';

  @override
  String get gOutlined => 'Contorneado';

  @override
  String get gSolid => 'Sólido';

  @override
  String get gFailed => 'Falló';

  @override
  String get gInvalid => 'Inválido';

  @override
  String get gNoEmpty => 'No puede estar vacío';

  @override
  String get gNothing => 'Nada';

  @override
  String get gRemoving => 'Eliminando';

  @override
  String get gSelfDestruct => 'Autodestrucción';

  @override
  String get gMachineTranslated =>
      'Todo está traducido por máquina. Si ves algún error, ¡por favor envía una corrección!\n';

  @override
  String get gTranslations => 'Enlace de traducciones.';

  @override
  String get gFix => 'Corregir...';

  @override
  String get gLauncherEntries => 'Entradas del lanzador';

  @override
  String get gSettingsEntries => 'Entradas de configuración';

  @override
  String get gsAppList => 'Lista de aplicaciones';

  @override
  String get gsLinkedList => 'Listas de inicio vinculadas';

  @override
  String get gsThemedHome =>
      '¡La lista de inicio también puede estar basada en temas!';

  @override
  String get gsNoBothHome =>
      'Nota: las páginas de inicio no tienen un sistema de actualizar ambos (';

  @override
  String get gsIndependent => ').\nLas listas serán totalmente independientes.';

  @override
  String get gsRelinked =>
      'Si se vuelve a vincular, se te preguntará qué versión conservar.';

  @override
  String get gsKeepWhich => '¿Qué diseño quieres conservar?';

  @override
  String get gsAutoSearch => 'Búsqueda automática en la lista de aplicaciones';

  @override
  String get gsHomeRipple => 'Animación de ondulación en inicio';

  @override
  String get gsListRipple => 'Animación de ondulación en lista';

  @override
  String get gsQuickLaunch => 'Inicio rápido';

  @override
  String get gsQLDescription =>
      'Desliza a la izquierda/derecha en la pantalla de inicio (excepto al editar) para abrir la aplicación seleccionada.\nMantén presionado para borrar tu selección.';

  @override
  String gsSwipe(Object direction) {
    return 'Deslizamiento hacia $direction';
  }

  @override
  String gsSwipeDesc(Object direction) {
    return 'Elige una aplicación de acceso rápido que se abrirá cuando deslices hacia $direction en la pantalla de inicio.';
  }

  @override
  String gsSwipeHint(Object direction) {
    return 'Elige la aplicación que se abre al deslizar hacia $direction';
  }

  @override
  String gsSwipeLabel(Object direction) {
    return 'Seleccionando el deslizamiento hacia $direction';
  }

  @override
  String get gsSecurity => 'Seguridad';

  @override
  String get gsAuthToEdit => 'Autenticación para editar listas/configuraciones';

  @override
  String get gsAuthForHidden => 'Autenticación para ver aplicaciones ocultas';

  @override
  String get gsAuthTimeout => 'Tiempo límite de autenticación (min)';

  @override
  String get gsPositiveOnly => 'Solo números enteros positivos';

  @override
  String get hsHome => 'Inicio';

  @override
  String get hsHomeHint => 'Inicio. Mantén presionado para editar.';

  @override
  String get hsWelcome => 'Bienvenido a Liminal Launcher';

  @override
  String get hsDescription =>
      'Está orientado al minimalismo,\npero tiene una personalización ilimitada.';

  @override
  String get hsUserSettings =>
      'Como regla general: ¡la apariencia de Liminal puede ser completamente independiente según el modo del tema!\n\nAl estar en los ajustes relevantes, verás un ícono alternable que indica si estás editando el oscuro ';

  @override
  String get hsLight => ', claro ';

  @override
  String get hsBoth => ', o ambos ';

  @override
  String get hsThemes => ' temas.';

  @override
  String get hsGetStarted =>
      'Mantén presionada la pantalla de inicio para comenzar.\n¡Gracias y disfruta!';

  @override
  String get hsOneMore => 'Una cosa más...';

  @override
  String get hsFree =>
      'Esta versión no es de la Play Store, por lo que debería haber sido gratis.\nTen la seguridad de que la versión gratuita de Liminal siempre será idéntica a la versión de Google Play.\n\nSi deseas apoyar el desarrollo de Liminal, o el desarrollo de más software genial, por favor considera ';

  @override
  String get hsContribute => 'contribuir';

  @override
  String get hsContributeHint =>
      'Abrir un enlace a las opciones de contribución';

  @override
  String get hsPopUp =>
      '.\n\nEsta es la única ventana emergente que no es un tutorial, y su única aparición en esta instalación.';

  @override
  String get hsOkay => 'Aceptar';

  @override
  String get hsApp => 'Aplicación';

  @override
  String get hsFolder => 'Carpeta';

  @override
  String get hsLane => 'Carril';

  @override
  String get hsSpacer => 'Espaciador';

  @override
  String get hsWidget => 'Widget';

  @override
  String get hsScreenLanes => ' carriles en pantalla.';

  @override
  String get hsWithCurr => 'Con tu actual...\n\ntamaño de ícono (';

  @override
  String get hsPadding => '),\nrelleno (';

  @override
  String get hsSpacing => '),\ny espaciado (';

  @override
  String get hsCanFit => '...pueden caber hasta ';

  @override
  String get hsWithMin => ' Con los valores mínimos, pueden caber hasta ';

  @override
  String get hsLanes => ' carriles.';

  @override
  String get hsEditAuth => 'Autentícate para editar el lanzador';

  @override
  String get hsHiddenAuth => 'Autentícate para ver aplicaciones ocultas';

  @override
  String get mcIconButton => 'Tamaño del botón de ícono';

  @override
  String get mcBanish => 'Desterrar';

  @override
  String get mcDelete => 'Eliminar';

  @override
  String get mcDone => 'Listo';

  @override
  String get mcHide => 'Ocultar';

  @override
  String get mcInfo => 'Información';

  @override
  String get mcReposition => 'Reposicionar';

  @override
  String get mcMove => 'Mover';

  @override
  String get mcMoveDown => 'Mover hacia abajo';

  @override
  String get mcMoveLeft => 'Mover hacia la izquierda';

  @override
  String get mcMoveRight => 'Mover hacia la derecha';

  @override
  String get mcMoveUp => 'Mover hacia arriba';

  @override
  String get mcRemove => 'Quitar';

  @override
  String get mcSave => 'Guardar';

  @override
  String get mcShow => 'Mostrar';

  @override
  String get mcUninstall => 'Desinstalar';

  @override
  String get mltLaneConfig => 'Configuración de múltiples carriles';

  @override
  String get mltPagesEnabled =>
      'Con las páginas habilitadas, los carriles se comportan como páginas en un lanzador tradicional.\n';

  @override
  String get mltPagesDisabled =>
      'Con las páginas deshabilitadas, todos los carriles comparten un desplazamiento horizontal.\n';

  @override
  String get mltWideEnabled => 'Con los mosaicos anchos habilitados...\n';

  @override
  String get mltWideWidth =>
      'cada carril (con un elemento) tendrá el ancho de una pantalla.\n';

  @override
  String get mltAnywhere =>
      'las aplicaciones y carpetas se podrán activar en cualquier parte de su espacio horizontal.\n';

  @override
  String get mltWideDisabled => 'Con los mosaicos anchos deshabilitados...\n';

  @override
  String get mltAutoWidth =>
      'los carriles se dimensionarán según su elemento más ancho y tus configuraciones de espaciado.\n';

  @override
  String get mltOnlyButton =>
      'las aplicaciones y carpetas se podrán activar únicamente a través de sus botones.\n';

  @override
  String get pHiddenReminder =>
      'Desliza hacia arriba mientras editas para abrir la lista de aplicaciones ocultas.';

  @override
  String get pReminder => 'Recordatorio';

  @override
  String pBanishApp(Object app) {
    return '¿Desterrar $app?';
  }

  @override
  String pRemoveLane(Object lane) {
    return '¿Quitar $lane?';
  }

  @override
  String get pWantTo => 'Quieres...';

  @override
  String get pHideDarkToo => '¿Ocultar también para el modo oscuro?';

  @override
  String get pHideLightToo => '¿Ocultar también para el modo claro?';

  @override
  String get pShowDarkToo => '¿Mostrar también para el modo oscuro?';

  @override
  String get pShowLightToo => '¿Mostrar también para el modo claro?';

  @override
  String pWhatBanish(Object undo) {
    return 'Cuando destierras una aplicación, seguirá instalada pero no aparecerá en Liminal en lo absoluto.\nLas aplicaciones desterradas solo se pueden abrir desde la configuración del sistema o mediante un enlace de la aplicación.\n\nDesterrar es útil para las aplicaciones de utilidad que también te hacen perder el tiempo. Por ejemplo, es posible que quieras desterrar tus navegadores web.\nDe esa manera, puedes usar los menús en línea cuando sales y reducir el desplazamiento compulsivo cuando te quedas en casa.\n\n$undo\n\nRecordatorio: desterrar es solo para la experiencia del usuario (UX), no para la seguridad.\nPor ejemplo: si una aplicación tiene permisos de ubicación siempre activos, desterrarla no afectará eso.';
  }

  @override
  String pUnBanish(Object app) {
    return 'La forma más sencilla de restaurar/quitar el destierro de $app es desinstalarla desde la configuración del sistema y luego volver a instalarla.';
  }

  @override
  String get srcCustom => 'Personalizado';

  @override
  String get srcName => 'Nombre ';

  @override
  String get srcBase => 'Sitio base ';

  @override
  String get srcPath => 'Ruta ';

  @override
  String get srcParameter => 'Parámetro ';

  @override
  String get srcNonEmpty => 'Se necesita un nombre que no esté vacío.';

  @override
  String get srcPlayResponsibly =>
      'Liminal realiza una validación mínima de estas entradas personalizadas.\nÚsalo bajo tu propio riesgo.';

  @override
  String get srcSameName =>
      'Ya existe una entrada personalizada con ese nombre.\nPor favor, cambia el nombre e inténtalo de nuevo.';

  @override
  String get thmSelector => 'selector';

  @override
  String get thmToggle => 'Alternar tema';

  @override
  String get timTitle => 'Temporizador';

  @override
  String get timHours => 'Horas';

  @override
  String get timMins => 'Minutos';

  @override
  String get timSecs => 'Segundos';

  @override
  String get timBadTime => 'Hora inválida';

  @override
  String get timQuick => 'Tiempos rápidos';

  @override
  String get togTitle => 'Controles multimedia';

  @override
  String get togFF => 'Avance rápido';

  @override
  String get togNext => 'Siguiente';

  @override
  String get togPlayPause => 'Reproducir/pausar';

  @override
  String get togPrevious => 'Anterior';

  @override
  String get togRewind => 'Rebobinar';

  @override
  String get togFFTog => 'Avance/Rebobinar';

  @override
  String get togSkipTog => 'Omitir/Anterior';

  @override
  String get togSomePlayers =>
      'Nota:\nEstos botones solo funcionan si el reproductor activo es compatible con ellos. Algunos reproductores de música no tienen la función de avance/rebobinar, por ejemplo';
}
