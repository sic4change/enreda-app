import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:enreda_app/app/home/curriculum/formation_form.dart';
import 'package:enreda_app/app/home/curriculum/stepper_experience_form.dart';
import 'package:enreda_app/app/home/curriculum/stepper_formation_form.dart';
import 'package:enreda_app/app/home/curriculum/tooltip_video/training_tooltip_video.dart';
import 'package:enreda_app/app/home/models/experience.dart';
import 'package:enreda_app/app/home/models/language.dart';
import 'package:enreda_app/app/home/models/trainingPill.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:enreda_app/app/home/web_home.dart';
import 'package:enreda_app/common_widgets/custom_text.dart';
import 'package:enreda_app/common_widgets/flex_row_column.dart';
import 'package:enreda_app/common_widgets/rounded_container.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enreda_app/utils/functions.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class CvData extends ChangeNotifier {
  // Ejemplo: usa tus TextEditingController / ValueNotifier ya existentes
  final tipoExperiencia = ValueNotifier<String?>(null);
  final sectorController = TextEditingController();
  final organismoController = TextEditingController();
  DateTime? fechaInicio;
  DateTime? fechaFin;

  bool get fechasOk =>
      fechaInicio != null &&
      fechaFin != null &&
      !fechaFin!.isBefore(fechaInicio!);

  @override
  void dispose() {
    sectorController.dispose();
    organismoController.dispose();
    tipoExperiencia.dispose();
    super.dispose();
  }
}

/// DEFINICIÓN DE PASOS
class StepMeta {
  final String id;
  StepMeta(this.id);
}

final steps = <StepMeta>[
  StepMeta('welcome'),
  StepMeta('formacion'),
  StepMeta('formacion_complementaria'),
  StepMeta('experiencia'),
  StepMeta('experiencia_personal'),
  StepMeta('about_me'),
  StepMeta('interests'),
  StepMeta('languages'),
  StepMeta('end'),
  // añade más...
];

/// HEADER DE PUNTOS
class StepperHeader extends StatelessWidget {
  const StepperHeader({
    super.key,
    required this.current,
    required this.onTap,
  });

  final int current;
  final ValueChanged<int> onTap;

  @override
Widget build(BuildContext context) {
  return LayoutBuilder(
    builder: (_, c) {
      return Row(
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            InkWell(
              onTap: i <= current ? () => onTap(i) : null, // sólo hacia atrás
              borderRadius: BorderRadius.circular(24),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // Relleno para hechos o actual; vacío para futuros
                      color: (i < current || i == current)
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      border: Border.all(
                        width: 2,
                        color: (i < current || i == current)
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.35),
                      ),
                    ),
                    // Puntito blanco SOLO en el paso actual (como en la captura)
                    child: i == current
                        ? Center(
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : null,
                  ),
                ],
              ),
            ),
            if (i != steps.length - 1)
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  height: 2,
                  // Línea activa en primario; inactiva con primario suave (no gris)
                  color: i < current
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.35),
                ),
              ),
          ],
        ],
      );
    },
  );
}

}

typedef BeforeNextHandler = Future<bool> Function();
final Map<String, BeforeNextHandler> _beforeNextByStepId = {};

/// WIZARD PRINCIPAL
class CvWizard extends StatefulWidget {
  const CvWizard({super.key, required this.user});
  final UserEnreda user;

  @override
  State<CvWizard> createState() => _CvWizardState();
}

class _CvWizardState extends State<CvWizard> {
  final data = CvData();

  // Un Form por paso
  final formKeys = List.generate(steps.length, (_) => GlobalKey<FormState>());
  int index = 0;
  
  // Preservar el estado del PageView
  final _pageStorageKey = const PageStorageKey<String>('cv_wizard_page');

  @override
  void initState() {
    super.initState();
    
    // Restaurar la posición guardada del PageView
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final savedIndex = PageStorage.of(context).readState(context, identifier: _pageStorageKey) as int?;
      if (savedIndex != null && savedIndex != index) {
        _goTo(savedIndex);
      }
    });
  }

  void _goTo(int i) {
    setState(() => index = i);
    
    // Guardar la posición actual en PageStorage
    PageStorage.of(context).writeState(context, i, identifier: _pageStorageKey);
  }

  bool _validateCurrent() {
    final ok = formKeys[index].currentState?.validate() ?? true;
    // validaciones cruzadas del paso (ej.: fechas)
    if (ok && steps[index].id == 'fechas' && !data.fechasOk) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La fecha fin debe ser posterior al inicio.')),
      );
      return false;
    }
    return ok;
  }

Future<void> _next() async {
  final stepId = steps[index].id;

  // Si el paso actual registró un handler (p. ej. StepFormation), úsalo
  if (_beforeNextByStepId.containsKey(stepId)) {
    final ok = await _beforeNextByStepId[stepId]!();
    if (!ok) return;
    if(!mounted) return;
  } else {
    // Si no hay handler, usa tu validación genérica
    //if (!_validateCurrent()) return;
  }

  if (index < steps.length - 1) {
    _goTo(index + 1);
  } else {
    _submit();
  }
}

  void _submit() {
    // TODO: persiste a tu backend / Firestore
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('CV guardado/enviado.')),
    );
  }

  void _saveDraft() async {
    final draftUser = widget.user.copyWith(cv_state: 'draft');
    final db = Provider.of<Database>(context, listen: false);
    _next();
    db.setUserEnreda(draftUser);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Borrador guardado.')),
    );
    setState(() {
      WebHome.controller.selectIndex(0);
    });
  }

  @override
  void dispose() {
    data.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RoundedContainer(
      margin: Responsive.isMobile(context) ? const EdgeInsets.all(0) :
        const EdgeInsets.all(Sizes.kDefaultPaddingDouble),
      contentPadding: Responsive.isMobile(context) ?
        EdgeInsets.all(Sizes.mainPadding) :
        EdgeInsets.all(Sizes.kDefaultPaddingDouble * 2),
      child: FocusTraversalGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomTextMediumBold(text: StringConst.MY_CV),
            const SizedBox(height: 16),
            StepperHeader(current: index, onTap: _goTo),
            const SizedBox(height: 16),
            Expanded(
              child: IndexedStack(
                index: index,
                children: [
                  _StepWelcome(key: formKeys[0], data: data),
                  _StepFormation(key: formKeys[1], isMainEducation: true, onSelectNoAndContinue: () => _goTo(index + 1), onSaveSiValido: (data) {}, title: 'Formación', question: '¿Quieres añadir alguna formación?', user: widget.user, registerBeforeNext: (fn) => _beforeNextByStepId['formacion'] = fn,),
                  _StepFormation(key: formKeys[2], isMainEducation: false, onSelectNoAndContinue: () => _goTo(index + 1), onSaveSiValido: (data) {}, title: 'Formación complementaria', question: '¿Quieres añadir alguna formación complementaria?', user: widget.user, registerBeforeNext: (fn) => _beforeNextByStepId['formacion_complementaria'] = fn,),
                  _StepExperience(key: formKeys[3], onSelectNoAndContinue: () => _goTo(index + 1), onSaveSiValido: (data) {}, user: widget.user, registerBeforeNext: (fn) => _beforeNextByStepId['experiencia'] = fn,),
                  _StepExperience(key: formKeys[4], onSelectNoAndContinue: () => _goTo(index + 1), onSaveSiValido: (data) {}, title: 'Experiencia personal', question: 'Ahora vamos con las experiencias personales', user: widget.user, registerBeforeNext: (fn) => _beforeNextByStepId['experiencia_personal'] = fn,),
                  _StepAboutMe(formKey: formKeys[5], data: data, user: widget.user, registerBeforeNext: (fn) => _beforeNextByStepId['about_me'] = fn,),
                  _StepInterests(key: formKeys[6], data: data, user: widget.user, registerBeforeNext: (fn) => _beforeNextByStepId['interests'] = fn,),
                  _StepLanguages(key: formKeys[7], user: widget.user, registerBeforeNext: (fn) => _beforeNextByStepId['languages'] = fn,),
                  _StepEnd(key: formKeys[8], user: widget.user, registerBeforeNext: (fn) => _beforeNextByStepId['end'] = fn,),
                  // añade más aquí...
                ],
              ),
            ),
            const SizedBox(height: 8),
            index == 0 ? 
            Container(
              height: 50,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.blue050),
                ),
                onPressed: index == 0 ? () => _goTo(index + 1) : null,
                child: const Text('Saltar vídeo y empezar CV', style: TextStyle(color: AppColors.blue050),),
              ),
            ) 
            : 
            _buildAcciones(context, index, _goTo, _saveDraft, _next), 
            
          ],
        ),
      ),
    );
  }
}

// Define un breakpoint a tu gusto
const double _mobileBreakpoint = 600;

Widget _buildAcciones(BuildContext context, int index, void Function(int) _goTo, void Function() _saveDraft, void Function() _next) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final isMobile = constraints.maxWidth < _mobileBreakpoint;

      final volverBtn = SizedBox(
        width: isMobile ? double.infinity : 200,
        height: 50,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.blue050),
          ),
          onPressed: index > 0 ? () => _goTo(index - 1) : null,
          child: const Text('Volver', style: TextStyle(color: AppColors.blue050)),
        ),
      );

      final borradorBtn = SizedBox(
        width: isMobile ? double.infinity : 200,
        height: 50,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.blue050),
          ),
          onPressed: _saveDraft,
          child: const Text('Guardar en borrador', style: TextStyle(color: AppColors.blue050)),
        ),
      );

      final siguienteBtn = SizedBox(
        width: isMobile ? double.infinity : 200,
        height: 50,
        child: FilledButton(
          onPressed: _next,
          child: Text(
            index == steps.length - 1 ? 'Finalizar' : 'Siguiente',
            style: const TextStyle(color: AppColors.white),
          ),
        ),
      );

      if (isMobile) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            volverBtn,
            const SizedBox(height: 12),
            borradorBtn,
            const SizedBox(height: 12),
            siguienteBtn,
          ],
        );
      } else {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            volverBtn,
            const SizedBox(width: 12),
            borradorBtn,
            const SizedBox(width: 12),
            siguienteBtn,
          ],
        );
      }
    },
  );
}


/// === PASO 1: Tipo de experiencia ===
class _StepWelcome extends StatefulWidget {
  const _StepWelcome({super.key, required this.data});
  final CvData data;

  @override
  State<_StepWelcome> createState() => _StepWelcomeState();
}

class _StepWelcomeState extends State<_StepWelcome> with AutomaticKeepAliveClientMixin {
  late YoutubePlayerController _controller;
  
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomTextMediumBold(text: StringConst.STEPPER_CV_TITLE_1),
        const SizedBox(height: 16),
        CustomTextMediumCenter(text: StringConst.STEPPER_CV_TEXT_1),
        const SizedBox(height: 20),
        StreamBuilder<TrainingPill>(
          stream: database.trainingPillStreamById(TrainingPill.HOW_TO_DO_CV_ID),
          builder: (context, snapshot) {
            if(snapshot.hasData) {
              TrainingPill trainingPill = snapshot.data!;
              trainingPill.setTrainingPillCategoryName();
              final videoId = YoutubePlayerController.convertUrlToId(trainingPill.urlVideo) ?? '';
              _controller = YoutubePlayerController.fromVideoId(
              videoId: videoId,
              autoPlay: false,
              params: const YoutubePlayerParams(
                showFullscreenButton: true,
              ),
            );
              return Container(
                width: MediaQuery.of(context).size.width > 600 ? MediaQuery.of(context).size.width/3.5 : MediaQuery.of(context).size.width,
                key: Key('trainingPill-${trainingPill.id}'),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary020,
                    width: 1.0,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: YoutubePlayer(
                      controller: _controller,
                    ),
                  ),
                ),
              );
            } else
            return Container();
          }),
      ],
    );
  }
}

class FormacionData {
  final String titulo;
  final String centro;
  final String nivel;
  final DateTime? inicio;
  final DateTime? fin;

  FormacionData({
    required this.titulo,
    required this.centro,
    required this.nivel,
    this.inicio,
    this.fin,
  });
  
}

class _EduItem {
  final String id;
  final Experience? exp;
  final bool isDraft;
  _EduItem({required this.id, required this.exp, required this.isDraft});
}


/// === PASO 1: Tipo de experiencia ===
class _StepFormation extends StatefulWidget {
  const _StepFormation({
    super.key,
    required this.onSelectNoAndContinue,
    required this.onSaveSiValido,
    required this.user,
    required this.registerBeforeNext,
    this.title = 'Experiencia profesional',
    this.question = '¿Qué tipo de experiencia quieres añadir?',
    this.isMainEducation = true,
  });

  final VoidCallback onSelectNoAndContinue;                // Avanzar si pulsa "No"
  final ValueChanged<FormacionData> onSaveSiValido;        // Callback tras guardar OK
  final UserEnreda user;                                   // <- nuevo (como en StepFormation)
  final void Function(Future<bool> Function()) registerBeforeNext; // <- nuevo
  final String title;
  final String question;
  final bool isMainEducation;

  @override
  State<_StepFormation> createState() => _StepFormationState();
}


class _StepFormationState extends State<_StepFormation>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  // Ya no usamos _activeIndex / _creatingNew ni los TextEditingController del padre.
  final _formKeysById = <String, GlobalKey<FormState>>{};
  final _stepperKeysById = <String, GlobalKey<StepperFormationFormState>>{};

  // Borradores "nueva formación"
  int _newCounter = 0;
  final List<String> _draftIds = []; // ej: ["_new_0", "_new_1", ...]
  String? _expandedId;

  bool? _tieneFormacion; // null = sin elegir, true = Sí, false = No
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    widget.registerBeforeNext(_validateSaveAndNotify);
  }

  // Crea/recupera keys estables por id
  GlobalKey<FormState> _formKeyFor(String id) =>
      _formKeysById.putIfAbsent(id, () => GlobalKey<FormState>());

  GlobalKey<StepperFormationFormState> _stepperKeyFor(String id) =>
      _stepperKeysById.putIfAbsent(id, () => GlobalKey<StepperFormationFormState>());

  void _addDraft() {
    final id = '_new_${_newCounter++}';
    setState(() {
      _draftIds.insert(0, id);   // << siempre arriba
      _expandedId = id;          // << abrirla al crear
    });
  }

  // Guardado masivo al pasar de paso (opción A: devolvemos la última)
  Future<bool> _validateSaveAndNotify() async {
    if (_tieneFormacion == false) return true;

    // Recolectamos todos los ids presentes en pantalla (existentes + borradores)
    final allIds = <String>[];
    if (mounted) {
      // Los existentes llegarán vía stream; aquí sólo guardamos lo que tengamos en _stepperKeysById
      allIds.addAll(_stepperKeysById.keys);
    }
    bool anyValid = false;
    FormacionData? lastData; // para Opción A

    for (final id in allIds) {
      final fk = _formKeysById[id];
      final sk = _stepperKeysById[id];
      if (fk?.currentState != null && fk!.currentState!.validate()) {
        anyValid = true;
        // Guarda en BD (el hijo conoce su Experience o es nuevo)
        await sk?.currentState?.saveExperience();

        // Si tu Stepper puede exponer los datos, ideal:
        // final data = sk?.currentState?.toFormacionData();
        // lastData = data;

        // Fallback: construye un placeholder mínimo si no puedes extraer data real
        lastData ??= FormacionData(
          titulo: '',
          centro: '',
          nivel: '',
          inicio: null,
          fin: null,
        );
      }
    }

    if (anyValid) {
      widget.onSaveSiValido(lastData ??
          FormacionData(titulo: '', centro: '', nivel: '', inicio: null, fin: null));
    }
    return anyValid;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final database = Provider.of<Database>(context, listen: false);
    final user = widget.user;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Título + pregunta
            Text(widget.title,
                style: TextStyle(
                  fontWeight: FontWeight.w100,
                  color: AppColors.primary900,
                  fontSize: 35,
                  fontFamily: GoogleFonts.outfit().fontFamily,
                )),
            const SizedBox(height: 8),
            Text(
              widget.question,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w800, color: AppColors.primary900, fontSize: 30),
            ),
            const SizedBox(height: 18),

            // Sí / No
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 16,
              children: [
                ChoiceCard(
                  selected: _tieneFormacion == true,
                  icon: Icons.check_rounded,
                  label: 'Sí',
                  onTap: () => setState(() => _tieneFormacion = true),
                ),
                ChoiceCard(
                  selected: _tieneFormacion == false,
                  icon: Icons.close_rounded,
                  label: 'No',
                  onTap: () => setState(() => _tieneFormacion = false),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Lista de tarjetas, cada una con su propio formulario
            if (_tieneFormacion == true)
              StreamBuilder<List<Experience>>(
                stream: database.myExperiencesStream(user.userId ?? ''),
                builder: (context, snapshot) {
                  if (!(snapshot.hasData && snapshot.connectionState == ConnectionState.active)) {
                    return const SizedBox.shrink();
                  }

                  final educationType =
                      widget.isMainEducation ? 'Formativa' : 'Complementaria';

                  final existing = snapshot.data!
                      .where((e) => e.type == educationType)
                      .toList();

                  final items = <_EduItem>[
                    ..._draftIds.map((id) => _EduItem(id: id, exp: null, isDraft: true)),
                    ...existing.map((exp) => _EduItem(
                          id: exp.id ?? exp.hashCode.toString(),
                          exp: exp,
                          isDraft: false,
                        )),
                  ];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final it in items)
                        _EducationFormCard(
                          id: it.id,
                          experience: it.exp,
                          isMainEducation: widget.isMainEducation,
                          expanded: _expandedId == it.id,
                          onToggle: () => setState(() {
                            _expandedId = (_expandedId == it.id) ? null : it.id;
                          }),
                          formKey: _formKeyFor(it.id),
                          stepperKey: _stepperKeyFor(it.id),
                          onSaved: () {
                           setState(() {
                            if (it.isDraft) {
                              _draftIds.remove(it.id);             
                              _formKeysById.remove(it.id);  
                              _stepperKeysById.remove(it.id);
                            }
                            _expandedId = null;               
                          });
                          },
                          onDelete: () async {
                            if (it.isDraft) {
                              setState(() {
                                _draftIds.remove(it.id);
                                if (_expandedId == it.id) _expandedId = null;
                              });
                            } else {
                              final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: Text('Eliminar formación'),
                                      content: Text('¿Confirmas la eliminación?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          child: const Text('Cancelar'),
                                        ),
                                        FilledButton.icon(
                                          icon: const Icon(Icons.delete_outline_rounded),
                                          onPressed: () => Navigator.of(context).pop(true),
                                          label: const Text('Eliminar'),
                                        ),
                                      ],
                                    ),
                                  ) ?? false;
                              if (!confirmed) return;
                              try {
                                await database.deleteExperience(it.exp!);
                                if (mounted && _expandedId == it.id) {
                                  setState(() => _expandedId = null);
                                }
                              } catch (e) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('No se pudo eliminar: $e')),
                                );
                              }
                            }
                          },
                        ),

                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: CreateEducationButton(onPressed: _addDraft),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _EducationFormCard extends StatelessWidget {
  const _EducationFormCard({
    required this.id,
    required this.isMainEducation,
    required this.formKey,
    required this.stepperKey,
    required this.expanded,
    required this.onToggle,
    this.experience,
    this.onDelete,
    this.onSaved,
  });

  final String id;
  final bool isMainEducation;
  final Experience? experience;
  final GlobalKey<FormState> formKey;
  final GlobalKey<StepperFormationFormState> stepperKey;

  // NUEVO:
  final bool expanded;
  final VoidCallback onToggle;

  final VoidCallback? onDelete;
  final VoidCallback? onSaved;

  @override
  Widget build(BuildContext context) {
    final title = (experience?.nameFormation ?? '').isNotEmpty
        ? experience!.nameFormation!
        : (experience == null ? 'Nueva formación' : 'Sin título');

    final subtitle = experience?.institution ?? (experience == null ? '' : '');

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.primary300.withOpacity(.6)),
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // HEADER: clickable para plegar/desplegar
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary900,
                                )),
                        if (subtitle.isNotEmpty)
                          Text(subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.primary900)),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0.0, // rota el chevron
                    duration: const Duration(milliseconds: 180),
                    child: const Icon(Icons.expand_more_rounded),
                  ),
                  if (onDelete != null)
                    IconButton(
                      tooltip: 'Eliminar',
                      icon: const Icon(Icons.delete_outline_rounded),
                      onPressed: onDelete,
                    ),
                ],
              ),
            ),
          ),

          // CUERPO: se muestra solo si expanded
          AnimatedCrossFade(
            crossFadeState:
                expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
            firstChild: const SizedBox(height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  StepperFormationForm(
                    isMainEducation: isMainEducation,
                    onComingBack: () {},
                    experience: experience, // null => vacío
                    formKey: formKey,
                    key: stepperKey,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      FilledButton.icon(
                        icon: const Icon(Icons.save_rounded),
                        label: const Text('Guardar'),
                        onPressed: () async {
                          final form = formKey.currentState;
                          if (form != null && form.validate()) {
                            try {
                               ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Formación guardada')),
                              );
                              await stepperKey.currentState?.saveExperience();
                              onSaved?.call();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('No se pudo guardar: $e')),
                              );
                            }
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      if (onDelete != null)
                        TextButton.icon(
                          icon: const Icon(Icons.close_rounded),
                          label: const Text('Descartar'),
                          onPressed: onDelete,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}



class _StepExperience extends StatefulWidget {
    _StepExperience({
    super.key,
    required this.onSelectNoAndContinue,
    required this.onSaveSiValido,
    required this.user,
    required this.registerBeforeNext,
    this.title = 'Experiencia profesional',
    this.question = '¿Qué tipo de experiencia quieres añadir?',
    this.isProfesional = false,
  });

  final VoidCallback onSelectNoAndContinue;                // Avanzar si pulsa "No"
  final ValueChanged<FormacionData> onSaveSiValido;        // Callback tras guardar OK
  final UserEnreda user;                                   // <- nuevo (como en StepFormation)
  final void Function(Future<bool> Function()) registerBeforeNext; // <- nuevo
  final String title;
  final String question;
  late bool isProfesional;

  @override
  State<_StepExperience> createState() => _StepExperienceState();
}


class _StepExperienceState extends State<_StepExperience>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  // Ya no usamos _activeIndex / _creatingNew ni los TextEditingController del padre.
  final _formKeysById = <String, GlobalKey<FormState>>{};
  final _stepperKeysById = <String, GlobalKey<StepperExperienceFormState>>{};

  // Borradores "nueva formación"
  int _newCounter = 0;
  final List<String> _draftIds = []; // ej: ["_new_0", "_new_1", ...]
  String? _expandedId;

  bool? _tieneExperiencia = true; // null = sin elegir, true = Sí, false = No
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    widget.registerBeforeNext(_validateSaveAndNotify);
  }

  // Crea/recupera keys estables por id
  GlobalKey<FormState> _formKeyFor(String id) =>
      _formKeysById.putIfAbsent(id, () => GlobalKey<FormState>());

  GlobalKey<StepperExperienceFormState> _stepperKeyFor(String id) =>
      _stepperKeysById.putIfAbsent(id, () => GlobalKey<StepperExperienceFormState>());

  void _addDraft() {
    final id = '_new_${_newCounter++}';
    setState(() {
      _draftIds.insert(0, id);   // << siempre arriba
      _expandedId = id;          // << abrirla al crear
    });
  }

  // Guardado masivo al pasar de paso (opción A: devolvemos la última)
  Future<bool> _validateSaveAndNotify() async {
    if (_tieneExperiencia == false) return true;

    // Recolectamos todos los ids presentes en pantalla (existentes + borradores)
    final allIds = <String>[];
    if (mounted) {
      // Los existentes llegarán vía stream; aquí sólo guardamos lo que tengamos en _stepperKeysById
      allIds.addAll(_stepperKeysById.keys);
    }
    bool anyValid = false;
    FormacionData? lastData; // para Opción A

    for (final id in allIds) {
      final fk = _formKeysById[id];
      final sk = _stepperKeysById[id];
      if (fk?.currentState != null && fk!.currentState!.validate()) {
        anyValid = true;
        // Guarda en BD (el hijo conoce su Experience o es nuevo)
        await sk?.currentState?.saveExperience();

        // Si tu Stepper puede exponer los datos, ideal:
        // final data = sk?.currentState?.toFormacionData();
        // lastData = data;

        // Fallback: construye un placeholder mínimo si no puedes extraer data real
        lastData ??= FormacionData(
          titulo: '',
          centro: '',
          nivel: '',
          inicio: null,
          fin: null,
        );
      }
    }

    if (anyValid) {
      widget.onSaveSiValido(lastData ??
          FormacionData(titulo: '', centro: '', nivel: '', inicio: null, fin: null));
    }
    return anyValid;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final database = Provider.of<Database>(context, listen: false);
    final user = widget.user;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Título + pregunta
            Text(widget.isProfesional ? 'Experiencia profesional' : 'Experiencia personal',
                style: TextStyle(
                  fontWeight: FontWeight.w100,
                  color: AppColors.primary900,
                  fontSize: 35,
                  fontFamily: GoogleFonts.outfit().fontFamily,
                )),
            const SizedBox(height: 8),
            Text(
              widget.question,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w800, color: AppColors.primary900, fontSize: 30),
            ),
            const SizedBox(height: 18),

            // Sí / No
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 16,
              children: [
                ChoiceCard(
                  selected: widget.isProfesional == true,
                  svgAsset: ImagePath.ICON_PROFESIONAL,
                  label: 'Profesional',
                  onTap: () => setState(() => widget.isProfesional = true),
                ),
                ChoiceCard(
                  selected: widget.isProfesional == false,
                  svgAsset: ImagePath.ICON_PERSONAL,
                  label: 'Personal',
                  onTap: () => setState(() => widget.isProfesional = false),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Lista de tarjetas, cada una con su propio formulario
            if (_tieneExperiencia == true)
              StreamBuilder<List<Experience>>(
                stream: database.myExperiencesStream(user.userId ?? ''),
                builder: (context, snapshot) {
                  if (!(snapshot.hasData && snapshot.connectionState == ConnectionState.active)) {
                    return const SizedBox.shrink();
                  }

                  final educationType =
                      widget.isProfesional ? 'Profesional' : 'Personal';

                  final existing = snapshot.data!
                      .where((e) => e.type == educationType)
                      .toList();

                  final items = <_EduItem>[
                    ..._draftIds.map((id) => _EduItem(id: id, exp: null, isDraft: true)),
                    ...existing.map((exp) => _EduItem(
                          id: exp.id ?? exp.hashCode.toString(),
                          exp: exp,
                          isDraft: false,
                        )),
                  ];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final it in items)
                        _ExperienceFormCard(
                          id: it.id,
                          experience: it.exp,
                          isProfesional: widget.isProfesional,
                          expanded: _expandedId == it.id,
                          onToggle: () => setState(() {
                            _expandedId = (_expandedId == it.id) ? null : it.id;
                          }),
                          formKey: _formKeyFor(it.id),
                          stepperKey: _stepperKeyFor(it.id),
                          onSaved: () {
                            setState(() {
                              if (it.isDraft) {
                                _draftIds.remove(it.id);              
                                _formKeysById.remove(it.id);          
                                _stepperKeysById.remove(it.id);
                              }
                              _expandedId = null;                     
                            });
                          },
                          onDelete: () async {
                            if (it.isDraft) {
                              setState(() {
                                _draftIds.remove(it.id);
                                if (_expandedId == it.id) _expandedId = null;
                              });
                            } else {
                              final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: Text('Eliminar formación'),
                                      content: Text('¿Confirmas la eliminación?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          child: const Text('Cancelar'),
                                        ),
                                        FilledButton.icon(
                                          icon: const Icon(Icons.delete_outline_rounded),
                                          onPressed: () => Navigator.of(context).pop(true),
                                          label: const Text('Eliminar'),
                                        ),
                                      ],
                                    ),
                                  ) ?? false;
                              if (!confirmed) return;
                              try {
                                await database.deleteExperience(it.exp!);
                                if (mounted && _expandedId == it.id) {
                                  setState(() => _expandedId = null);
                                }
                              } catch (e) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('No se pudo eliminar: $e')),
                                );
                              }
                            }
                          },
                        ),

                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: CreateEducationButton(onPressed: _addDraft),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _ExperienceFormCard extends StatelessWidget {
  const _ExperienceFormCard({
    required this.id,
    required this.isProfesional,
    required this.formKey,
    required this.stepperKey,
    required this.expanded,
    required this.onToggle,
    this.experience,
    this.onDelete,
    this.onSaved,
  });

  final String id;
  final bool isProfesional;
  final Experience? experience;
  final GlobalKey<FormState> formKey;
  final GlobalKey<StepperExperienceFormState> stepperKey;


  // NUEVO:
  final bool expanded;
  final VoidCallback onToggle;

  final VoidCallback? onDelete;
  final VoidCallback? onSaved;

  @override
  Widget build(BuildContext context) {
    final title = (experience?.activity ?? '').isNotEmpty
        ? experience!.activity!
        : (experience == null ? 'Nueva experiencia' : 'Sin título');

    final subtitle = experience?.institution ?? (experience == null ? '' : '');

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.primary300.withOpacity(.6)),
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // HEADER: clickable para plegar/desplegar
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary900,
                                )),
                        if (subtitle.isNotEmpty)
                          Text(subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.primary900)),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0.0, // rota el chevron
                    duration: const Duration(milliseconds: 180),
                    child: const Icon(Icons.expand_more_rounded),
                  ),
                  if (onDelete != null)
                    IconButton(
                      tooltip: 'Eliminar',
                      icon: const Icon(Icons.delete_outline_rounded),
                      onPressed: onDelete,
                    ),
                ],
              ),
            ),
          ),

          // CUERPO: se muestra solo si expanded
          AnimatedCrossFade(
            crossFadeState:
                expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
            firstChild: const SizedBox(height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  StepperExperienceForm(
                    isProfesional: isProfesional,
                    experience: experience, // null => vacío
                    formKey: formKey,
                    key: stepperKey,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      FilledButton.icon(
                        icon: const Icon(Icons.save_rounded),
                        label: const Text('Guardar'),
                        onPressed: () async {
                          final form = formKey.currentState;
                          if (form != null && form.validate()) {
                            try {
                              /*ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Experiencia guardada')),
                              );*/
                              await stepperKey.currentState?.saveExperience();
                              onSaved?.call();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('No se pudo guardar: $e')),
                              );
                            }
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      if (onDelete != null)
                        TextButton.icon(
                          icon: const Icon(Icons.close_rounded),
                          label: const Text('Descartar'),
                          onPressed: onDelete,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


/// === PASO 3: Organismo ===
class _StepOrganismo extends StatefulWidget {
  const _StepOrganismo({super.key, required this.data});
  final CvData data;

  @override
  State<_StepOrganismo> createState() => _StepOrganismoState();
}

class _StepOrganismoState extends State<_StepOrganismo> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Form(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('¿En qué tipo de organismo la realizaste?',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              TextFormField(
                controller: widget.data.organismoController,
                decoration: const InputDecoration(
                  labelText: 'Empresa/organización',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// === PASO 4: Fechas ===
class _StepAboutMe extends StatefulWidget {
  const _StepAboutMe({super.key, required this.data, required this.user, required this.registerBeforeNext, required this.formKey});
  final CvData data;
  final UserEnreda user;
  final void Function(Future<bool> Function()) registerBeforeNext;
  final GlobalKey<FormState> formKey;

  @override
  State<_StepAboutMe> createState() => _StepAboutMeState();
}

class _StepAboutMeState extends State<_StepAboutMe> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  TextEditingController textController = TextEditingController();


  @override
  void initState() {
    super.initState();
    textController.text = widget.user.aboutMe ?? '';
    widget.registerBeforeNext(_validateSaveAndNotify);
  }

Future<bool> _validateSaveAndNotify() async {
  // Captura dependencias ANTES del await
  final db = Provider.of<Database>(context, listen: false);
  final updated = widget.user.copyWith(aboutMe: textController.text);

  try {
    await db.setUserEnreda(updated);
  } catch (e) {
    if (mounted) {
      // Si quieres, muestra error AQUÍ (usa context antes de avanzar de paso)
     
        print('No se pudo guardar: $e');
      
    }
    return false;
  }
  setGamificationFlag(context: context, flagId: UserEnreda.FLAG_CV_ABOUT_ME);

  return true;
}



  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Form(
      key: widget.formKey,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('¿Qué puedes contarnos de ti?', style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w800, color: AppColors.primary900, fontSize: 30),),
              SpaceH20(),
              AutoGrowTextFormField(
                controller: textController, // o initialValue: '...'
                hint:
                    'Aquí te proponemos un ejemplo: Soy una persona responsable y con muchas ganas '
                    'de aprender. Me gusta trabajar en equipo y ayudar a los demás. En mi último '
                    'trabajo como dependiente, aprendí a tratar con clientes y resolver problemas rápidamente.',
                minLines: 5,              // arranque alto como en la captura
                maxLines: null,           // que crezca libremente
                textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Este campo es obligatorio' : null,
              ),
              
              const SizedBox(height: 8),
              
            ],
          ),
        ),
      ),
    );
  }
}

class _StepInterests extends StatefulWidget {
  const _StepInterests({super.key, required this.data, required this.user, required this.registerBeforeNext});
  final CvData data;
  final UserEnreda user;
  final void Function(Future<bool> Function()) registerBeforeNext;

  @override
  State<_StepInterests> createState() => _StepInterestsState();
}

class _StepInterestsState extends State<_StepInterests> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<String> _skills = [];

  @override
  void initState() {
    super.initState();
    _skills = widget.user.dataOfInterest;
    widget.registerBeforeNext(_validateSaveAndNotify);
  }

  Future<bool> _validateSaveAndNotify() async {
    final db = Provider.of<Database>(context, listen: false);
    final updated = widget.user.copyWith(dataOfInterest: _skills);
    await db.setUserEnreda(updated);
    setGamificationFlag(context: context, flagId: UserEnreda.FLAG_CV_DATA_OF_INTEREST);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final defaults = [
      'Carnet de conducir', 'Deportes', 'Lectura', 'Pintura y Dibujo',
      'Fotografía', 'Viajar', 'Arte', 'Gastronomía', 'Danza',
      'Juegos y tecnología', 'Cine y series', 'Senderismo', 'Meditación',
    ];
    return Form(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('¿Hay algo más que las empresas deban saber sobre ti?', style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w800, color: AppColors.primary900, fontSize: 30),),
              SpaceH20(),
              SkillsSelector(
                defaultOptions: defaults,
                selected: _skills,
                onChanged: (list) => setState(() => _skills = list),
                addLabel: 'Añade nueva habilidad',
                inputHint: 'Escribe una habilidad',
              ),
              
              const SizedBox(height: 8),
              
            ],
          ),
        ),
      ),
    );
  }
}

class _StepLanguages extends StatefulWidget {
  const _StepLanguages({super.key, required this.user, required this.registerBeforeNext});
  final UserEnreda user;
  final void Function(Future<bool> Function()) registerBeforeNext;

  @override
  State<_StepLanguages> createState() => _StepLanguagesState();
}

class _StepLanguagesState extends State<_StepLanguages> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final _stepperKey = GlobalKey<LanguagesLevelSectionState>();


  @override
  void initState() {
    super.initState();
    widget.registerBeforeNext(_validateSaveAndNotify);
  }
  
  Future<bool> _validateSaveAndNotify() async {
    _stepperKey.currentState?.saveAndNotify();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Form(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('¿Qué idioma quieres añadir?', style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w800, color: AppColors.primary900, fontSize: 30),),
              SpaceH20(),
              LanguagesLevelSection(
                key: _stepperKey,
                initialLanguages: widget.user.languagesLevels,
                onChanged: (list) => {},
                user: widget.user,
              ),
              
              const SizedBox(height: 8),
              
            ],
          ),
        ),
      ),
    );
  }
}


class _StepEnd extends StatefulWidget {
  const _StepEnd({super.key, required this.user, required this.registerBeforeNext});
  final UserEnreda user;
  final void Function(Future<bool> Function()) registerBeforeNext;
  

  @override
  State<_StepEnd> createState() => _StepEndState();
}

class _StepEndState extends State<_StepEnd> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    widget.registerBeforeNext(_validateSaveAndNotify);
  }
  
  Future<bool> _validateSaveAndNotify() async {
    final db = Provider.of<Database>(context, listen: false);
    final updated = widget.user.copyWith(cv_state: 'completed');
    await db.setUserEnreda(updated);
    return true;
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Form(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('¡Buen trabajo!', style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w800, color: AppColors.primary900, fontSize: 30),),
              SpaceH20(),
             Text('Siempre podrás editar y actualizar tu currículum.\n ¿Quieres visualizarlo?', style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w300, color: AppColors.primary900, fontSize: 26),
                  textAlign: TextAlign.center,),
              
              const SizedBox(height: 20),

              Expanded(
                flex: 5,
                child: Image.asset(
                  height: 300,
                  ImagePath.STEPPER_CV_END,
                  fit: BoxFit.cover,
                ),
              ),
              
               const SizedBox(height: 40),

            ],
          ),
        ),
      ),
    );
  }
}


class ChoiceCard extends StatelessWidget {
  const ChoiceCard({
    super.key,
    required this.selected,
    this.icon,
    this.svgAsset,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.iconSize = 20,
    this.circleSize = 36,
    this.widthFactor = 4.5,
  }) : assert(
          (icon != null) ^ (svgAsset != null),
          'Debes proporcionar exactamente uno: icon O svgAsset.',
        );

  final bool selected;
  final String label;
  final VoidCallback onTap;

  final IconData? icon;
  final String? svgAsset;

  final Color? iconColor;
  final double iconSize;
  final double circleSize;
  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    final borderColor = selected ? primary : AppColors.grey120;
    final borderWidth = selected ? 3.0 : 1.0;
    final isSvg = svgAsset != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: MediaQuery.of(context).size.width > 600 ? MediaQuery.of(context).size.width/widthFactor : MediaQuery.of(context).size.width/3,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            // Ícono con círculo (modo icon) o sólo la imagen (modo svg)
            Container(
              width: circleSize,
              height: circleSize,
              // Sin decoración si es SVG (sin reborde)
              decoration: isSvg
                  ? null
                  : BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: borderColor, width: 1.6),
                    ),
              alignment: Alignment.center,
              child: _buildLeading(primary),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeading(Color primary) {
    if (icon != null) {
      return Icon(icon, size: iconSize, color: iconColor ?? primary);
    }
    // SVG: sin colorFilter para respetar los colores originales
    return SvgPicture.asset(
      svgAsset!,
      width: iconSize + 25,
      height: iconSize + 25,
      fit: BoxFit.contain,
    );
  }
}



/// TextFormField que crece según el número de líneas escritas,
/// manteniendo la decoración de _appDecoration.
class AutoGrowTextFormField extends StatelessWidget {
  const AutoGrowTextFormField({
    super.key,
    this.controller,
    this.initialValue,
    required this.hint,
    this.minLines = 4,          // altura inicial como en el mock
    this.maxLines,              // déjalo null para crecimiento libre
    this.textStyle,
    this.onChanged,
    this.validator,
    this.maxLength,             // opcional: límite de caracteres
  }) : assert(controller == null || initialValue == null,
         'No puedes usar controller e initialValue a la vez');

  final TextEditingController? controller;
  final String? initialValue;
  final String hint;
  final int minLines;
  final int? maxLines;
  final TextStyle? textStyle;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      minLines: minLines,
      maxLines: maxLines, // null => crece sin límite
      style: textStyle ?? theme.textTheme.bodyMedium?.copyWith(height: 1.5),
      onChanged: onChanged,
      validator: validator,
      maxLength: maxLength,
      // Oculta el contador si se define maxLength
      buildCounter: maxLength == null
          ? null
          : (context, {required int currentLength, required bool isFocused, int? maxLength}) => null,
      decoration: _appDecoration(hint).copyWith(
        // Para que el hint largo se muestre en varias líneas
        hintMaxLines: 6,
        alignLabelWithHint: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      ),
      // Calidad de escritura
      autocorrect: true,
      enableSuggestions: true,
    );
  }
}

 InputDecoration _appDecoration(String hintText) {
    const radius = 30.0;
    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: const BorderSide(color: AppColors.primary100, width: 1),
    );

    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: AppColors.greyHint, fontSize: 12),
      filled: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      enabledBorder: baseBorder,
      disabledBorder: baseBorder,
      focusedBorder: baseBorder.copyWith(
        borderSide: const BorderSide(color: AppColors.primary100, width: 3),
      ),
      errorBorder: baseBorder.copyWith(
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
      focusedErrorBorder: baseBorder.copyWith(
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }


/// Selector de opciones estilo “píldoras” con sugerencias + entrada libre.
/// - defaultOptions: lista de sugerencias (aparecen con +)
/// - selected: lista de seleccionados (se muestran con ✔)
/// - onChanged: callback con la lista actualizada
class SkillsSelector extends StatefulWidget {
  const SkillsSelector({
    super.key,
    required this.defaultOptions,
    required this.selected,
    required this.onChanged,
    this.addLabel = 'Añade nueva habilidad',
    this.inputHint = 'Escribe una habilidad',
    this.runSpacing = 12,
    this.spacing = 14,
  });

  final List<String> defaultOptions;
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  final String addLabel;
  final String inputHint;
  final double runSpacing;
  final double spacing;

  @override
  State<SkillsSelector> createState() => _SkillsSelectorState();
}

class _SkillsSelectorState extends State<SkillsSelector> {
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List<String>.from(widget.selected);
  }

  String _normalize(String s) =>
      s.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

  bool _isSelected(String label) =>
      _selected.map(_normalize).contains(_normalize(label));

  void _toggle(String label) {
    final norm = _normalize(label);
    final idx = _selected.indexWhere((e) => _normalize(e) == norm);
    setState(() {
      if (idx >= 0) {
        _selected.removeAt(idx);
      } else {
        _selected.add(label.trim());
      }
    });
    widget.onChanged(List.unmodifiable(_selected));
  }

  Future<void> _addCustomDialog() async {
    final ctrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Añadir habilidad', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            decoration: _appDecoration(widget.inputHint),
            onSubmitted: (v) => Navigator.of(ctx).pop(v),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(ctrl.text),
              child: const Text('Añadir'),
            ),
          ],
        );
      },
    );

    if (result != null && result.trim().isNotEmpty) {
      // Evitar duplicados (case-insensitive)
      if (!_isSelected(result)) {
        setState(() => _selected.add(result.trim()));
        widget.onChanged(List.unmodifiable(_selected));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Para no duplicar: solo pintamos custom que no estén en las sugerencias
    final defaultNorms = widget.defaultOptions.map(_normalize).toSet();
    final customSelected = _selected
        .where((s) => !defaultNorms.contains(_normalize(s)))
        .toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.primary100, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Botón "Añade nueva habilidad"
          InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: _addCustomDialog,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary100, width: 1.5),
                    ),
                    child: const Icon(Icons.add_rounded,
                        size: 22, color: AppColors.primary100),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.addLabel,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.primary100,
                      fontWeight: FontWeight.w400,
                      fontSize: 14
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Sugerencias
          Wrap(
            spacing: widget.spacing,
            runSpacing: widget.runSpacing,
            children: [
              for (final opt in widget.defaultOptions)
                _TagPill(
                  label: opt,
                  selected: _isSelected(opt),
                  onTap: () => _toggle(opt),
                ),
              // Custom seleccionados (no presentes en defaultOptions)
              for (final custom in customSelected)
                _TagPill(
                  label: custom,
                  selected: true,
                  onTap: () => _toggle(custom),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Píldora visual con borde “pill” y badge de + / ✔
class _TagPill extends StatelessWidget {
  const _TagPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor =
        selected ? theme.colorScheme.primary : AppColors.primary100;
    final borderWidth = selected ? 3.0 : 1.0;
    final icon =
        selected ? Icons.check_rounded : Icons.add_rounded; // ✔ o +

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge circular
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 1.6),
              ),
              child: Icon(icon, size: 16, color: borderColor),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color:AppColors.greyDark,
                fontWeight: FontWeight.w400,
                fontSize: 14
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LanguagesLevelSection extends StatefulWidget {
  const LanguagesLevelSection({
    super.key,
    this.initialLanguages,
    required this.onChanged,
    required this.user,
  });

  /// Si no pasas nada, se crean Español/Francés/Inglés por defecto.
  final List<Language>? initialLanguages;
  final ValueChanged<List<Language>> onChanged;
  final UserEnreda user;

  @override
  State<LanguagesLevelSection> createState() => LanguagesLevelSectionState();
}

class LanguagesLevelSectionState extends State<LanguagesLevelSection> {
  late List<Language> _langs;

  @override
  void initState() {
    super.initState();
    _langs = widget.initialLanguages ??
        [
          Language(name: 'Español', speakingLevel: 1, writingLevel: 1),
          Language(name: 'Francés', speakingLevel: 1, writingLevel: 1),
          Language(name: 'Inglés', speakingLevel: 1, writingLevel: 1),
        ];
  }

  Future<void> saveAndNotify() async {
    final db = Provider.of<Database>(context, listen: false);
    final updated = widget.user.copyWith(languagesLevels: _langs);
    await db.setUserEnreda(updated);
    print('languages saved');
  }

  void _notify() => widget.onChanged(List.unmodifiable(_langs));

  Future<void> _addLanguage() async {
    final added = await showAddLanguageDialog(context);
    if (added != null) {
      setState(() => _langs.add(added));
      _notify();
    }
  }

    void _updateLang(int index, {int? speaking, int? writing}) {
    final curr = _langs[index];
    final updated = Language(
      name: curr.name,
      speakingLevel: speaking ?? curr.speakingLevel,
      writingLevel: writing ?? curr.writingLevel,
    );
    setState(() => _langs[index] = updated);
    _notify();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < _langs.length; i++) ...[
          LanguageLevelCard(
            key: ValueKey('lang_${i}_${_langs[i].name}'),
            language: _langs[i],
            onSpeakingChanged: (v) => _updateLang(i, speaking: v.toInt()),
            onWritingChanged: (v) => _updateLang(i, writing: v.toInt()),
          ),
          const SizedBox(height: 18),
        ],

        // Botón "Añadir otro idioma"
        Align(
          alignment: Alignment.centerLeft,
          child: InkWell(
            onTap: _addLanguage,
            borderRadius: BorderRadius.circular(28),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0x0F13B8A6), // un fondo suave (ajústalo a tu paleta)
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 34, height: 34,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary900, // círculo lleno
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Añadir otro idioma',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.greyDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class LanguageLevelCard extends StatelessWidget {
  const LanguageLevelCard({
    super.key,
    required this.language,
    required this.onSpeakingChanged,
    required this.onWritingChanged,
  });

  final Language language;
  final ValueChanged<double> onSpeakingChanged;
  final ValueChanged<double> onWritingChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.primary100, width: 1),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 700;
          final content = [
            // Badge de idioma + nombre
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary100, width: 1.5),
                  ),
                  child: const Icon(Icons.translate, color: AppColors.primary900, size: 26),
                ),
                const SizedBox(width: 12),
                Text(
                  language.name,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),

            // Expresión oral
            _RatingRow(
              label: 'Expresión oral',
              value: language.speakingLevel.toDouble(),
              onChanged: onSpeakingChanged,
            ),

            // Expresión escrita
            _RatingRow(
              label: 'Expresión escrita',
              value: language.writingLevel.toDouble(),
              onChanged: onWritingChanged,
            ),
          ];

          return isNarrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    content[0],
                    const SizedBox(height: 12),
                    content[1],
                    const SizedBox(height: 10),
                    content[2],
                  ],
                )
              : Row(
                  children: [
                    content[0],
                    const Spacer(),
                    content[1],
                    const SizedBox(width: 24),
                    content[2],
                  ],
                );
        },
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  const _RatingRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;            // 0..3
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(width: 12),
        SmoothStarRating(
          starCount: 3,
          rating: value,
          allowHalfRating: false,
          onRatingChanged: onChanged,
          size: 22,
          spacing: 10,
          filledIconData: Icons.circle,           // ● seleccionado
          defaultIconData: Icons.circle_outlined, // ○ vacío
          color: AppColors.primary900,
          borderColor: AppColors.primary900,
        ),
      ],
    );
  }
}

Future<Language?> showAddLanguageDialog(BuildContext context, {Language? initial}) {
  int speakingLevel = initial?.speakingLevel ?? 0;
  int writingLevel  = initial?.writingLevel  ?? 0;
  final nameCtrl = TextEditingController(text: initial?.name ?? '');

  return showDialog<Language>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (ctx, set) {
          return AlertDialog(
            title: Text(initial == null ? 'Añadir idioma' : 'Editar idioma'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Idioma')),
                const SizedBox(height: 12),
                _buildSpeakingLevelRow(
                  value: speakingLevel.toDouble(),
                  textTheme: Theme.of(ctx).textTheme,
                  onValueChanged: (v) => set(() => speakingLevel = v.toInt()),
                ),
                const SizedBox(height: 12),
                _buildWritingLevelRow(
                  value: writingLevel.toDouble(),
                  textTheme: Theme.of(ctx).textTheme,
                  onValueChanged: (v) => set(() => writingLevel = v.toInt()),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
              FilledButton(
                onPressed: () {
                  final lang = Language(
                    name: nameCtrl.text.trim(),
                    speakingLevel: speakingLevel,
                    writingLevel: writingLevel,
                  );
                  Navigator.pop(ctx, lang);
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      );
    },
  );
}


Widget _buildSpeakingLevelRow({
  required TextTheme textTheme,
  required double value,
  double iconSize = 22.0,
  Function(double)? onValueChanged,
}) {
  return Row(
    children: [
      Expanded(
        child: Text('Expresión oral', style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.normal)),
      ),
      SmoothStarRating(
        allowHalfRating: false,
        onRatingChanged: onValueChanged,
        starCount: 3,
        rating: value,
        size: iconSize,
        filledIconData: Icons.circle,
        defaultIconData: Icons.circle_outlined,
        color: AppColors.primary900,
        borderColor: AppColors.primary900,
        spacing: 10.0,
      ),
    ],
  );
}

Widget _buildWritingLevelRow({
  required TextTheme textTheme,
  required double value,
  double iconSize = 22.0,
  Function(double)? onValueChanged,
}) {
  return Row(
    children: [
      Expanded(
        child: Text('Expresión escrita', style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.normal)),
      ),
      SmoothStarRating(
        allowHalfRating: false,
        onRatingChanged: onValueChanged,
        starCount: 3,
        rating: value,
        size: iconSize,
        filledIconData: Icons.circle,
        defaultIconData: Icons.circle_outlined,
        color: AppColors.primary900,
        borderColor: AppColors.primary900,
        spacing: 10.0,
      ),
    ],
  );
}


// Tarjeta plegada con lápiz de editar
class _CollapsedExperienceTile extends StatelessWidget {
  const _CollapsedExperienceTile({
    required this.title,
    required this.subtitle,
    required this.onEdit,
    required this.onDelete,
  });

  final String title;
  final String subtitle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
      color: AppColors.primary500,
    );
    final subtitleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: AppColors.greyAlt,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary500),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          const Icon(Icons.menu_book_rounded, size: 22),
          const SizedBox(width: 12),

          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: title.toUpperCase(), style: titleStyle),
                  const TextSpan(text: ' - '),
                  TextSpan(text: subtitle.toUpperCase(), style: subtitleStyle),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ),

          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Editar',
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_rounded),
            color: AppColors.red,
            tooltip: 'Eliminar',
          ),
        ],
      ),
    );
  }
}


class CreateEducationButton extends StatelessWidget {
  const CreateEducationButton({
    super.key,
    required this.onPressed,
    this.label = 'Crear nueva formación',
  });

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    const pillBg = Color(0xFFEFF6F6); // fondo claro (puedes ajustarlo)
    final dark = AppColors.primary900; // tu color principal oscuro

    return Material(
      color: pillBg,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: dark,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.add, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontFamily: GoogleFonts.outfit().fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      color: dark,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}





