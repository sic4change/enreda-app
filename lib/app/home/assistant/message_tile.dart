import 'package:chips_choice/chips_choice.dart';
import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:enreda_app/app/home/models/chatQuestion.dart';
import 'package:enreda_app/app/home/models/choice.dart';
import 'package:enreda_app/app/home/models/question.dart';
import 'package:enreda_app/common_widgets/custom_chip.dart';
import 'package:enreda_app/common_widgets/show_alert_dialog.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:flutter/foundation.dart';
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
  });

  final Question question;
  final ChatQuestion chatQuestion;
  final ValueNotifier<List<Choice>> currentChoicesNotifier;
  static String? experienceTypeId, experienceSubtypeId;
  static List<String> recommendedActivities = [];

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  List<String> _choicesSelected = [];
  List<Choice> _choices = [];
  DateTime dateResponse = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final database = Provider.of<Database>(context, listen: false);

    if (widget.question.type == StringConst.MULTICHOICE_QUESTION &&
        _choices.isEmpty) {
      _loadResponseChoices();
    }

    return Container(
      child: Column(
        children: [
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
                      setState(() {
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
                              setState(() {
                                _choicesSelected = [val];
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
          if (widget.question.type == StringConst.DATE_QUESTION &&
              widget.chatQuestion.userResponse == null)
            _buildDateResponse(),
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
          color: Constants.chatLightBlue,
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
    return ChipsChoice<String>.single(
      choiceItems: C2Choice.listFrom<String, String>(
        source: source,
        value: (i, v) => v,
        label: (i, v) => v,
      ),
      choiceBuilder: (item, i) => CustomChip(
        label: item.label,
        borderRadius: 7.0,
        backgroundColor: Constants.chatLightBlue,
        selectedBackgroundColor: Constants.chatDarkBlue,
        textColor: Constants.chatDarkGray,
        selected: item.selected,
        onSelect: item.select!,
      ),
      onChanged: onChanged,
      wrapped: true,
      runSpacing: 8,
      value: widget.currentChoicesNotifier.value.isNotEmpty
          ? widget.currentChoicesNotifier.value[0].name
          : '',
    );
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
        backgroundColor: Constants.chatLightBlue,
        selectedBackgroundColor: Constants.chatDarkBlue,
        textColor: Constants.chatDarkGray,
        selected: item.selected,
        onSelect: item.select!,
      ),
      onChanged: (val) {
        if (val.length > widget.question.optionsToSelect!) {
          showAlertDialog(
            context,
            title: 'Aviso',
            content:
                'Número máximo de respuestas a seleccionar: ${widget.question.optionsToSelect!}',
            defaultActionText: 'Ok',
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
          setState(() {
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

  Widget _buildDateResponse() {
    return Container(
      width: 150.0,
      height: 80.0,
      margin: EdgeInsets.only(left: 20),
      padding: EdgeInsets.all(20),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(50)),
      ),
      child: DateTimeField(
        initialValue: dateResponse,
        format: DateFormat('MM/yyyy'),
        decoration: InputDecoration(
          suffixIcon: Icon(
            Icons.event,
          ),
        ),
        style: Theme.of(context).textTheme.bodyLarge,
        onShowPicker: (context, currentValue) {
          return showDatePicker(
            context: context,
            locale: Locale('es', 'ES'),
            firstDate: new DateTime(DateTime.now().year - 100,
                DateTime.now().month, DateTime.now().day),
            initialDate: currentValue ?? DateTime.now(),
            lastDate: DateTime.now(),
          );
        },
        onChanged: (dateTime) {
          setState(() {
            dateResponse = dateTime!;
            widget.currentChoicesNotifier.value = [
              Choice(id: '', name: dateResponse.toString())
            ];
          });
        },
      ),
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
          color: Constants.chatDarkBlue,
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

    database
        .choicesStream(widget.question.choicesCollection!, typeId, subtypeId)
        .first
        .then((value) => value.forEach((choice) {
              setState(() {
                if (!_choices.any((element) => element.id == choice.id))
                  _choices.add(choice);

                if (widget.question.choicesCollection ==
                        StringConst.ACTIVITIES_CHOICES &&
                    _choicesSelected.contains(choice.name)) {
                  if (!widget.currentChoicesNotifier.value
                      .any((element) => element.id == choice.id))
                    widget.currentChoicesNotifier.value.add(choice);
                }
              });
            }))
        .whenComplete(() => _choices
            .sort((a, b) => _choicesSelected.contains(a.name) ? 1 : -1));
  }
}
