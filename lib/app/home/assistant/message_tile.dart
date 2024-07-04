import 'package:chips_choice/chips_choice.dart';
import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:enreda_app/app/home/models/chatQuestion.dart';
import 'package:enreda_app/app/home/models/choice.dart';
import 'package:enreda_app/app/home/models/question.dart';
import 'package:enreda_app/app/home/models/trainingPill.dart';
import 'package:enreda_app/app/home/trainingPills/videos_tooltip_widget/chat_pill_video.dart';
import 'package:enreda_app/common_widgets/custom_chip.dart';
import 'package:enreda_app/common_widgets/show_alert_dialog.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/utils/responsive.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'chat_room_tile_style.dart';

class MessageTile extends StatefulWidget {
  MessageTile({
    required this.question,
    required this.chatQuestion,
    required this.currentChoicesNotifier,
    required this.sourceAutoCompleteNotifier,
    this.showSportOptions,
    required this.onNext,
  });

  final Question question;
  final ChatQuestion chatQuestion;
  final ValueNotifier<List<Choice>> currentChoicesNotifier;
  final ValueNotifier<List<Choice>> sourceAutoCompleteNotifier;
  static String? experienceTypeId, experienceSubtypeId;
  static List<String> recommendedActivities = [];
  ValueNotifier<bool>? showSportOptions;
  final VoidCallback onNext;

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  List<String> _choicesSelected = [];
  List<Choice> _choices = [];
  DateTime dateResponse = DateTime.now();
  TextEditingController? _dateController;
  bool _isAwaitingCompletion = true;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController();
  }

  @override
  void dispose() {
    if (!_isAwaitingCompletion) {
      _dateController?.dispose();
    }
    super.dispose();
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final database = Provider.of<Database>(context, listen: false);

    if (widget.question.type == StringConst.MULTICHOICE_QUESTION &&
        _choices.isEmpty) {
      widget.sourceAutoCompleteNotifier.value.clear();
      _loadResponseChoices();
    }

    return Container(
      child: Column(
        children: [
          if (widget.question.type == StringConst.VIDEO_QUESTION)
            _buildQuestion(
                child: StreamBuilder<TrainingPill>(
                    stream: database.trainingPillStreamById(TrainingPill.WHAT_ARE_COMPETENCIES_ID),
                    builder: (context, snapshot) {
                      if(snapshot.hasData) {
                        TrainingPill trainingPill = snapshot.data!;
                        trainingPill.setTrainingPillCategoryName();
                        return Container(
                          key: Key('trainingPill-${trainingPill.id}'),
                          child: Column(
                            children: [
                              Text(
                                  widget.question.text.replaceAll(StringConst.USERNAME_PATTERN,
                                      auth.currentUser!.displayName!),
                                  textAlign: TextAlign.start,
                                  style: chatRoomQuestionStyle()),
                              SpaceH12(),
                              ChatPillVideo(trainingPill: trainingPill, onNext: widget.onNext,),
                            ],
                          ),
                        );
                      } else
                        return Container();
                    })
            ),
          if (widget.question.type != StringConst.VIDEO_QUESTION)
            _buildQuestion(
              child: Text(
                  widget.question.text.replaceAll(StringConst.USERNAME_PATTERN,
                      auth.currentUser!.displayName!),
                  textAlign: TextAlign.start,
                  style: chatRoomQuestionStyle()),
            ),
          if (widget.question.link != null)
            _buildQuestion(
              child: InkWell(
                child: Text(widget.question.link!,
                    textAlign: TextAlign.start,
                    style: chatRoomQuestionStyle()
                        .copyWith(decoration: TextDecoration.underline)),
                onTap: () => launch(widget.question.link!),
              ),
            ),
          if (widget.question.type == StringConst.YES_NO_QUESTION &&
              widget.chatQuestion.userResponse == null)
            Container(
                alignment: Alignment.center,
                child: _buildSingleChoiceResponse(
                    source: [
                      widget.question.confirmResponse!.text,
                      widget.question.negativeResponse!.text,
                    ],
                    onChanged: (val) {
                      setStateIfMounted(() {
                        widget.currentChoicesNotifier.value = [
                          Choice(id: '', name: val)
                        ];
                      });
                    })),
          if (widget.question.type == StringConst.MULTICHOICE_QUESTION &&
              widget.chatQuestion.userResponse == null)
            _choices.isNotEmpty
                ? Container(
                alignment: Alignment.center,
                child: widget.question.optionsToSelect == 1
                    ? _buildSingleChoiceResponse(
                    source: _choices.map((e) => e.name).toList(),
                    onChanged: (val) {
                      setStateIfMounted(() {
                        _choicesSelected = [val];
                        //_choices.forEach((element) {widget.sourceAutoCompleteNotifier.value.add(element.name);});
                        final choice = _choices.firstWhere(
                                (element) => element.name == val);
                        widget.currentChoicesNotifier.value = [
                          Choice(
                              id: choice.id,
                              name: choice.name,
                              competencies: choice.competencies),
                        ];
                        if (choice.activities.isNotEmpty) {
                          MessageTile.recommendedActivities.clear();
                          choice.activities.forEach((activityId) {
                            database
                                .activityStream(activityId)
                                .first
                                .then((activity) => MessageTile
                                .recommendedActivities
                                .add(activity.name));
                          });
                        }

                        if (widget.question.experienceField ==
                            StringConst.EXPERIENCE_TYPE_FIELD)
                          MessageTile.experienceTypeId = choice.id;
                        if (widget.question.experienceField ==
                            StringConst.EXPERIENCE_SUBTYPE_FIELD)
                          MessageTile.experienceSubtypeId = choice.id;
                      });
                    })
                    : _buildMultiChoiceResponse(context))
                : CircularProgressIndicator(),
          if (widget.chatQuestion.userResponse != null) _buildUserResponse(),
        ],
      ),
    );
  }

  Widget _buildQuestion({required Widget child}) {
    return Container(
      padding: EdgeInsets.only(
          top: 8,
          bottom: 8,
          right: Constants.mainPadding,
          left: Constants.mainPadding),
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(Constants.mainPadding),
        decoration: BoxDecoration(
          color: AppColors.primary050,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(23),
              topRight: Radius.circular(23),
              bottomRight: Radius.circular(23)),
          /*gradient: LinearGradient(
              colors: [const Color(0xFF579ACA), const Color(0xFF4E92B1)],
            )*/
        ),
        child: child,
      ),
    );
  }

  Widget _buildSingleChoiceResponse(
      {required List<String> source, required Function(String) onChanged}) {
    return source.length <= 9  || Responsive.isMobile(context) || (widget.showSportOptions?.value ?? false) ?
    ChipsChoice<String>.single(
      choiceItems: C2Choice.listFrom<String, String>(
        source: source,
        value: (i, v) => v,
        label: (i, v) => v,
      ),
      choiceBuilder: (item, i) => CustomChip(
        label: item.label,
        borderRadius: 7.0,
        backgroundColor: AppColors.primary010,
        selectedBackgroundColor: AppColors.primary500,
        textColor: AppColors.primary900,
        selected: item.selected,
        onSelect: item.select!,
      ),
      onChanged: onChanged,
      wrapped: true,
      runSpacing: 8,
      value: widget.currentChoicesNotifier.value.isNotEmpty
          ? widget.currentChoicesNotifier.value[0].name
          : '',
    ) : Container();
  }

  Widget _buildMultiChoiceResponse(BuildContext context) {
    //final minSelectedActivities = 3;
    return ChipsChoice<String>.multiple(
      choiceItems: C2Choice.listFrom<String, String>(
        source: _choices.map((e) => e.name).toList(),
        value: (i, v) => v,
        label: (i, v) => v,
      ),
      choiceBuilder: (item, i) => CustomChip(
        label: item.label,
        borderRadius: 7.0,
        backgroundColor: AppColors.primary010,
        selectedBackgroundColor: AppColors.primary500,
        textColor: AppColors.primary900,
        selected: item.selected,
        onSelect: item.select!,
      ),
      onChanged: (val) {
        if (val.length > widget.question.optionsToSelect!) {
          showAlertDialog(
            context,
            title: StringConst.CHAT_TITLE_QUESTION,
            content:
            StringConst.CHAT_MESSAGE_WARNING + '${widget.question.optionsToSelect!}',
            defaultActionText: StringConst.FORM_ACCEPT,
          );
        }
        /*else if (val.length < minSelectedActivities &&
            widget.question.choicesCollection ==
                StringConst.ACTIVITIES_CHOICES) {
          showAlertDialog(
            context,
            title: 'Aviso',
            content: 'Selecciona al menos ${minSelectedActivities} actividades',
            defaultActionText: 'Ok',
          );
        }*/
        else {
          setStateIfMounted(() {
            _choicesSelected = val;
            widget.currentChoicesNotifier.value.clear();
            val.forEach((choiceName) {
              final choice =
              _choices.firstWhere((choice) => choice.name == choiceName);
              widget.currentChoicesNotifier.value.add(Choice(
                  id: choice.id,
                  name: choice.name,
                  competencies: choice.competencies));
            });
            if (widget.question.choicesCollection ==
                StringConst.ACTIVITIES_CHOICES)
              _choices
                  .sort((a, b) => _choicesSelected.contains(a.name) ? 1 : -1);
          });
        }
      },
      value: _choicesSelected,
      wrapped: true,
      runSpacing: 8,
    );
  }

  Widget _buildUserResponse() {
    String userText = widget.chatQuestion.userResponse!;
    if (widget.question.type == StringConst.MULTICHOICE_QUESTION &&
        widget.question.optionsToSelect! > 1)
      userText = userText.replaceAll(StringConst.SEPARATOR, ', ');
    if (widget.question.type == StringConst.DATE_QUESTION) {
      final month = '${DateTime.parse(userText).month}'.padLeft(2, '0');
      final year = '${DateTime.parse(userText).year}';
      userText = '$month/$year';
    }
    return Container(
      padding: EdgeInsets.only(
          top: 8,
          bottom: 8,
          right: Constants.mainPadding,
          left: Constants.mainPadding),
      alignment: Alignment.centerRight,
      child: Container(
        padding: EdgeInsets.only(
            top: 17,
            bottom: 17,
            left: Constants.mainPadding,
            right: Constants.mainPadding),
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(23),
              topRight: Radius.circular(23),
              bottomLeft: Radius.circular(23)),
        ),
        child: Text(userText,
            textAlign: TextAlign.start, style: chatRoomResponseStyle()),
      ),
    );
  }

  void _loadResponseChoices() {
    final database = Provider.of<Database>(context, listen: false);
    String? typeId, subtypeId;
    if (widget.question.choicesCollection == StringConst.ACTIVITY_CHOICES ||
        widget.question.choicesCollection ==
            StringConst.ACTIVITY_ROLE_CHOICES) {
      typeId = MessageTile.experienceTypeId;
      subtypeId = MessageTile.experienceSubtypeId;
    }

    if (widget.question.choicesCollection == StringConst.ACTIVITIES_CHOICES) {
      _choicesSelected = MessageTile.recommendedActivities;
    }

    database.choicesStream(widget.question.choicesCollection!, typeId, subtypeId).first
        .then((value) => value.forEach((choice) {
      setStateIfMounted(() {
        if (!_choices.any((element) => element.id == choice.id))
          _choices.add(choice);

        if (widget.question.choicesCollection == StringConst.ACTIVITIES_CHOICES &&
            _choicesSelected.contains(choice.name)) {
          if (!widget.currentChoicesNotifier.value.any((element) => element.id == choice.id))
            widget.currentChoicesNotifier.value.add(choice);
        }
        _choices.forEach((element) {widget.sourceAutoCompleteNotifier.value.add(element);});
      });
    }))
        .whenComplete(() {
      if (!_choices.any((c) => c.order == null)) {
        _choices.sort((a,b) => a.order!.compareTo(b.order!));
      } else {
        _choices.sort((a, b) => _choicesSelected.contains(a.name) ? 1 : -1);
      }
    });
  }
}