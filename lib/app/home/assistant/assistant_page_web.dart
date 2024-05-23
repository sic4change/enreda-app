import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enreda_app/app/home/assistant/simple_text_style.dart';
import 'package:enreda_app/app/home/models/chatQuestion.dart';
import 'package:enreda_app/app/home/models/choice.dart';
import 'package:enreda_app/app/home/models/experience.dart';
import 'package:enreda_app/app/home/models/question.dart';
import 'package:enreda_app/app/home/assistant/list_item_builder.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:enreda_app/common_widgets/show_alert_dialog.dart';
import 'package:enreda_app/common_widgets/show_competencies.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/services/database.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/utils/functions.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:enreda_app/values/values.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import '../../anallytics/analytics.dart';
import 'message_tile.dart';

class AssistantPageWeb extends StatefulWidget {
  const AssistantPageWeb({Key? key, required this.onClose}) : super(key: key);
  final void Function(bool showSuccessMessage, String gamificationFlagName) onClose;

  @override
  _AssistantPageWebState createState() => _AssistantPageWebState();
}

class _AssistantPageWebState extends State<AssistantPageWeb> {
  TextEditingController messageEditingController = new TextEditingController();
  List<Question> questions = [];
  List<ChatQuestion> chatQuestions = [];
  ValueNotifier<List<Choice>> currentChoicesNotifier =
      ValueNotifier<List<Choice>>([]);
  List<List<Choice>> choicesLog = [];
  ValueNotifier<bool> isWritingNotifier = ValueNotifier<bool>(false);
  ValueNotifier<String> isTextEnabledNotifier = ValueNotifier<String>('');
  ValueNotifier<List<Choice>> sourceAutoCompleteNotifier =  ValueNotifier<List<Choice>>([]);
  late ChatQuestion _currentChatQuestion;
  late FocusNode _focusNode = FocusNode();
  ValueNotifier<bool> showSportOptions = ValueNotifier<bool>(false);



  Map<String, int> userCompetencies = {};

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  @override
  void initState() {
    super.initState();
    _resetQuestions();
    setGamificationFlag(context: context, flagId: UserEnreda.FLAG_CHAT);
    setGamificationFlag(context: context, flagId: UserEnreda.FLAG_PILL_COMPETENCIES);
  }

  @override
  void dispose() {
    currentChoicesNotifier.dispose();
    isWritingNotifier.dispose();
    isTextEnabledNotifier.dispose();
    sourceAutoCompleteNotifier.dispose();
    messageEditingController.dispose();
    MessageTile.experienceTypeId = null;
    MessageTile.experienceSubtypeId = null;
    showSportOptions.value = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);
    sendBasicAnalyticsEvent(context, "enreda_app_open_chat");
    return StreamBuilder<User?>(
        stream: Provider.of<AuthBase>(context).authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Material(
              child: Container(
                color: Constants.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      height: 60,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [
                              AppColors.greenCheckIcon,
                              AppColors.turquoiseBlue,
                            ],
                            begin: const FractionalOffset(0.0, 0.0),
                            end: const FractionalOffset(0.5, 0.0),
                            stops: [0.0, 1.0],
                            tileMode: TileMode.clamp),
                      ),
                      child: Row(
                        children: [
                          SpaceW20(),
                          Image.asset(ImagePath.LOGO_WHITE_CHAT,
                              color: Constants.white, width: 30),
                          SpaceW20(),
                          Text(
                            StringConst.CHAT_TITLE,
                            style: TextStyle(
                                color: Constants.white,
                                fontWeight: FontWeight.w500),
                          ),
                          Expanded(
                            child: Container(),
                          ),
                          IconButton(
                              onPressed: () => widget.onClose(false, ""),
                              icon: Icon(
                                Icons.close,
                                color: Constants.white,
                              )),
                        ],
                      ),
                    ),
                    Expanded(child: _buildChat(context)),
                    Padding(
                      padding: const EdgeInsets.only(left: 30.0),
                      child: _buildIsWritingAnimation(),
                    ),
                    _buildWriteMessageContainer(database),
                  ],
                ),
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator(),);
          }
        }
    );
  }

  Widget _buildChat(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final database = Provider.of<Database>(context, listen: false);
    return Container(
        child: StreamBuilder<List<ChatQuestion>>(
      stream: database.chatQuestionsStream(auth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            snapshot.data!.isNotEmpty &&
            snapshot.connectionState == ConnectionState.active &&
            snapshot.data!.any((element) => element.id != null) &&
            snapshot.data!.any((element) => element.show)) {
          _currentChatQuestion =
              snapshot.data!.firstWhere((element) => element.show);

          chatQuestions = snapshot.data!;
          return ListItemBuilder<ChatQuestion>(
              snapshot: snapshot,
              itemBuilder: (context, chatQuestion) {
                return StreamBuilder<Question>(
                    stream: database.questionStream(chatQuestion.questionId),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        final question = snapshot.data!;
                        if (chatQuestion.show) {
                          return MessageTile(
                            question: question,
                            chatQuestion: chatQuestion,
                            currentChoicesNotifier: currentChoicesNotifier,
                            sourceAutoCompleteNotifier: sourceAutoCompleteNotifier,
                            showSportOptions: showSportOptions,
                            onNext: () => _showNextChatQuestion(question, [], database),
                          );
                        } else {
                          return Container();
                        }
                      } else {
                        return Container();
                      }
                    });
              });
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    ));
  }

  Widget _buildIsWritingAnimation() {
    return ValueListenableBuilder<bool>(
        valueListenable: isWritingNotifier,
        builder: (context, isWriting, child) {
          return isWriting
              ? Container(
                  height: 20.0,
                  width: 20.0,
                  child: LoadingIndicator(
                    indicatorType: Indicator.ballPulse /*Indicator.pacman*/,
                    colors: [
                      AppColors.primary100,
                      AppColors.primary500,
                      AppColors.turquoiseBlue,
                    ],
                    backgroundColor: Constants.white,
                  ),
                )
              : Container(
                  width: 0.0,
                  height: 20.0,
                );
        });
  }

  Widget _buildWriteMessageContainer(Database database) {
    return Container(
      height: 60.0,
      color: Constants.chatLightGray,
      padding: EdgeInsets.symmetric(horizontal:Constants.mainPadding),
      child: Row(
        children: [
          ValueListenableBuilder<bool>(
              valueListenable: isWritingNotifier,
              builder: (context, isWriting, child) {
                return Container(
                    padding: EdgeInsets.only(
                      right: Constants.mainPadding,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.backspace_outlined),
                      color: AppColors.primary500,
                      onPressed: () => isWriting ? {} : _editLastResponse(),
                    ));
              }),
          ValueListenableBuilder<String>(
              valueListenable: isTextEnabledNotifier,
              builder: (context, isTextEnabled, child) {
                return Expanded(
                    child: isTextEnabled == 'multichoice' ? _autocompleteTextField( (val) {
                      setState(() {
                        final choice = sourceAutoCompleteNotifier.value.firstWhere(
                                (element) => element.name == val);
                        currentChoicesNotifier.value = [
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
                        final question = questions.firstWhere((element) =>
                        element.id == _currentChatQuestion.questionId);

                     if (question.experienceField ==
                            StringConst.EXPERIENCE_TYPE_FIELD)
                         MessageTile.experienceTypeId = choice.id;
                        if (question.experienceField ==
                           StringConst.EXPERIENCE_SUBTYPE_FIELD)
                          MessageTile.experienceSubtypeId = choice.id;
                      });
                    }, database, messageEditingController)
                    : TextField(
                  enabled: isTextEnabled == 'text',
                  controller: messageEditingController,
                  style: simpleTextStyle(),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(10.0, 1.0, 5.0, 10.0),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      hintText: StringConst.CHAT_WRITE,
                      hintStyle: TextStyle(
                        color: Colors.grey,
                      )),
                )
                );
              }),
          ValueListenableBuilder<List<Choice>>(
              valueListenable: currentChoicesNotifier,
              builder: (context, currentChoice, child) {
                return Container(
                  margin: EdgeInsets.only(left: Constants.mainPadding),
                  child: IconButton(
                      hoverColor: Colors.transparent,
                      icon: Icon(Icons.send),
                      color: AppColors.primary500,
                      onPressed: () {
                        final question = questions.firstWhere((element) =>
                            element.id == _currentChatQuestion.questionId);

                        if ((question.type == StringConst.YES_NO_QUESTION ||
                                question.type ==
                                    StringConst.MULTICHOICE_QUESTION) &&
                            currentChoice.isEmpty) {
                          messageEditingController.clear();
                          setState(() {
                            showSportOptions.value = true;
                          });
                          showAlertDialog(
                            this.context,
                            title: StringConst.CHAT_TITLE_QUESTION,
                            content: StringConst.CHAT_SELECT,
                            defaultActionText: StringConst.OK,
                          );
                          return;
                        }

                        if (question.type == StringConst.TEXT_QUESTION &&
                            messageEditingController.text.isEmpty) {
                          showAlertDialog(
                            this.context,
                            title: StringConst.CHAT_TITLE_QUESTION,
                            content: StringConst.CHAT_ANSWER_QUESTION,
                            defaultActionText: StringConst.OK,
                          );
                          return;
                        }

                        final minSelectedActivities = 3;
                        if (currentChoice.length < minSelectedActivities &&
                            question.choicesCollection ==
                                StringConst.ACTIVITIES_CHOICES) {
                          showAlertDialog(
                            context,
                            title: StringConst.CHAT_TITLE_QUESTION,
                            content:
                             StringConst.CHAT_SELECT1_QUESTION + '${minSelectedActivities}' + StringConst.CHAT_SELECT2_QUESTION,
                            defaultActionText: StringConst.OK,
                          );
                          return;
                        }

                        _saveUserResponse(question, database, currentChoice);

                        if (question.isLastQuestion != null &&
                            question.isLastQuestion!) {
                          _addExperience();
                        } else {
                          _showNextChatQuestion(
                              question, currentChoice, database);
                        }
                      }),
                );
              }),
        ],
      ),
    );
  }

  Widget _autocompleteTextField(Function(String) onChanged, Database database, TextEditingController messageEditingController) {
    return ValueListenableBuilder(
      valueListenable: sourceAutoCompleteNotifier,
      builder: (context, source, child) {
        return RawAutocomplete<String>(optionsBuilder: (textEditingValue){
          if(textEditingValue.text.isEmpty){
            return List.empty();
          }else{
            return source.where((element) => element.name.toLowerCase().contains(textEditingValue.text.toLowerCase())).map((e) => e.name).toSet().toList();
          }
        },
          textEditingController: messageEditingController,
          focusNode: _focusNode,
          onSelected: onChanged,
          fieldViewBuilder: (context, messageEditingController, focusNode, onFieldSubmitted){
          _focusNode = focusNode;
          return TextField(
            controller: messageEditingController,
            focusNode: focusNode,
            onEditingComplete: onFieldSubmitted,
            decoration: const InputDecoration(hintText: StringConst.CHAT_SEARCH),
          );
        },
            optionsViewBuilder: (BuildContext context,
            AutocompleteOnSelected<String> onSelected,
            Iterable<String> options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4.0,
              child: SizedBox(
                height: 60.0,
                width: 300,
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: options.where((element) => element.toLowerCase().contains(messageEditingController.text.toLowerCase())).length,
                  itemBuilder: (BuildContext context, int index) {
                    final String option = options.elementAt(index);
                    return GestureDetector(
                      onTap: () {
                        onSelected(option);
                      },
                      child: SizedBox(
                        height: 40,
                        child: ListTile(
                          title:
                            Text(option, style: Theme.of(context).textTheme.bodyLarge),
                          //visualDensity: VisualDensity(vertical: -2),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
        );
      },
    );
  }

  void _saveUserResponse(
      Question question, Database database, List<Choice> currentChoice) {
    choicesLog.add(List.from(currentChoice));
    currentChoice.forEach((choice) {
      if (choice.competencies.isNotEmpty) {
        choice.competencies.keys.forEach((competencyId) {
          userCompetencies.update(competencyId,
              (value) => value + choice.competencies[competencyId]!,
              ifAbsent: () => choice.competencies[competencyId]!);
        });
      }
    });

    switch (question.type) {
      case StringConst.YES_NO_QUESTION:
      case StringConst.MULTICHOICE_QUESTION:
        var response = '';
        currentChoice.forEach((choice) {
          response = '$response${choice.name}${StringConst.SEPARATOR}';
        });
        response = response.substring(0, response.length - 1);

        database.updateChatQuestion(
            _currentChatQuestion.copyWith(userResponse: response));
        break;
      case StringConst.DATE_QUESTION:
        if (currentChoice.isEmpty) {
          currentChoice = [Choice(id: '', name: DateTime.now().toString())];
        }
        database.updateChatQuestion(
            _currentChatQuestion.copyWith(userResponse: currentChoice[0].name));
        break;
      case StringConst.TEXT_QUESTION:
        database.updateChatQuestion(_currentChatQuestion.copyWith(
            userResponse: messageEditingController.text));
        break;
    }
  }

  void _showNextChatQuestion(
      Question question, List<Choice> currentChoice, Database database) async {
    final auth = Provider.of<AuthBase>(context, listen: false);
    messageEditingController.clear();
    isWritingNotifier.value = true;
    await Future.delayed(Duration(seconds: 1 + Random().nextInt(2)));
    isWritingNotifier.value = false;

    late ChatQuestion nextChatQuestion;
    late Question nextQuestion;

    switch (question.type) {
      case StringConst.YES_NO_QUESTION:
        final currentChoiceText = currentChoice[0].name;
        nextChatQuestion = currentChoiceText == question.confirmResponse!.text
            ? chatQuestions.firstWhere((element) =>
                element.questionId == question.confirmResponse!.nextQuestionId)
            : chatQuestions.firstWhere((element) =>
                element.questionId ==
                question.negativeResponse!.nextQuestionId);
        nextQuestion = questions
            .firstWhere((element) => element.id == nextChatQuestion.questionId);
        break;

      case StringConst.MULTICHOICE_QUESTION:
        if (question.hasMultipleNextQuestions ?? false) {
          final selectedChoice = question.choices!
              .firstWhere((choice) => choice.choiceId == currentChoice[0].id);
          nextChatQuestion = chatQuestions.firstWhere((chatQuestion) =>
              chatQuestion.questionId == selectedChoice.nextQuestionId);

          nextQuestion = questions.firstWhere(
              (element) => element.id == nextChatQuestion.questionId);
        } else {
          nextChatQuestion = chatQuestions.firstWhere((chatQuestion) =>
              chatQuestion.questionId == question.nextQuestionId);

          nextQuestion = questions.firstWhere(
              (element) => element.id == nextChatQuestion.questionId);
        }

        break;

      case StringConst.TEXT_QUESTION:
      case StringConst.DATE_QUESTION:
      case StringConst.NONE_QUESTION || StringConst.VIDEO_QUESTION:
        // TODO: Check if question.order + 1 is valid in every case
        nextQuestion = questions
            .firstWhere((element) => element.order == question.order + 1);

        nextChatQuestion = chatQuestions
            .firstWhere((element) => element.questionId == nextQuestion.id);
        break;
    }

    database.updateChatQuestion(nextChatQuestion.copyWith(show: true));

    if (nextQuestion.order == 6) {
      final userEnreda =
          await database.userStream(auth.currentUser!.email).first;
      if (userEnreda.isNotEmpty) {
        userEnreda[0].updateShowChatWelcome(false);
        database.setUserEnreda(userEnreda[0]);
      }
    }

    if (nextQuestion.type == StringConst.NONE_QUESTION) {
      _showNextChatQuestion(nextQuestion, currentChoice, database);
    }

    if (nextQuestion.type == StringConst.TEXT_QUESTION) {
      isTextEnabledNotifier.value = 'text';
    } else {
      isTextEnabledNotifier.value = '';
    }
    if (nextQuestion.type == StringConst.MULTICHOICE_QUESTION) {
      isTextEnabledNotifier.value = 'multichoice';
    }

    currentChoicesNotifier.value.clear();
  }

  void _resetQuestions() async {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final database = Provider.of<Database>(context, listen: false);

    questions = await database.questionsStream().first;
    chatQuestions =
        await database.chatQuestionsStream(auth.currentUser!.uid).first;

    var timestamp = Timestamp.now();
    questions.forEach((question) {
      bool showQuestion = false;
      if (question.order == 1 || question.order == 2 /*|| question.order == 3*/)
        showQuestion = true;

      final chatQuestion = chatQuestions.firstWhere(
          (element) => element.questionId == question.id,
          orElse: () => ChatQuestion(
              date: timestamp,
              questionId: question.id,
              userId: auth.currentUser!.uid,
              userResponse: null,
              show: showQuestion));
      if (chatQuestion.id == null) {
        database.addChatQuestion(chatQuestion);
      } else {
        database.updateChatQuestion(
            chatQuestion.copyWith(userResponse: null, show: showQuestion));
      }
      //TODO: Create the next Timestamp later to make sure that we create every question with a difference of time but it doesn't feel optimum
      timestamp = Timestamp.fromMillisecondsSinceEpoch(
          timestamp.millisecondsSinceEpoch + 1000);
    });
  }

  void _editLastResponse() async {
    final database = Provider.of<Database>(context, listen: false);

    Question _currentQuestion = questions.firstWhere(
        (question) => question.id == _currentChatQuestion.questionId);
    if (_currentQuestion.order == 1 || _currentQuestion.order == 2 || _currentQuestion.order == 3) return;

    await database
        .updateChatQuestion(_currentChatQuestion.copyWith(show: false));

    _currentChatQuestion =
        chatQuestions.firstWhere((chatQuestion) => chatQuestion.show);
    await database
        .updateChatQuestion(_currentChatQuestion.copyWith(userResponse: null));

    _currentQuestion = questions.firstWhere(
        (question) => question.id == _currentChatQuestion.questionId);
    if (_currentQuestion.type == StringConst.TEXT_QUESTION) {
      isTextEnabledNotifier.value = 'text';
    } else {
      isTextEnabledNotifier.value = '';
    }
    if (_currentQuestion.type == StringConst.MULTICHOICE_QUESTION){
      isTextEnabledNotifier.value = 'multichoice';
    }

    if (_currentQuestion.experienceField == StringConst.EXPERIENCE_TYPE_FIELD)
      MessageTile.experienceTypeId = null;
    if (_currentQuestion.experienceField ==
        StringConst.EXPERIENCE_SUBTYPE_FIELD)
      MessageTile.experienceSubtypeId = null;

    choicesLog.last.forEach((choice) {
      if (choice.competencies.isNotEmpty) {
        choice.competencies.keys.forEach((competencyId) {
          userCompetencies.update(competencyId,
              (value) => value - choice.competencies[competencyId]!);
        });
      }
    });

    userCompetencies.removeWhere((key, value) => value == 0);
    choicesLog.removeLast();
    messageEditingController.clear();
    setState(() {
      sourceAutoCompleteNotifier.notifyListeners();
      showSportOptions.value = false;
    });

    if (_currentQuestion.type == StringConst.NONE_QUESTION) {
      _editLastResponse();
    }
    messageEditingController.clear();
    messageEditingController.value = TextEditingValue.empty;
  }

  void _addExperience() async {
    final database = Provider.of<Database>(context, listen: false);
    final auth = Provider.of<AuthBase>(context, listen: false);

    late String type;
    String? subtype;
    String? activity;
    String? activityRole;
    String? activityLevel;
    List<String> professionActivities = [];
    String? peopleAffected;
    String? organization;
    Timestamp? startDate;
    Timestamp? endDate;
    String location = "";
    String workType = "";
    String experienceContext = "";
    String experienceContextPlace = "";

    chatQuestions =
        await database.chatQuestionsStream(auth.currentUser!.uid).first;

    chatQuestions.forEach((chatQuestion) {
      final question = questions
          .firstWhere((question) => chatQuestion.questionId == question.id);
      if (chatQuestion.show && question.experienceField != null) {
        switch (question.experienceField) {
          case 'type':
            type = chatQuestion.userResponse!;
            break;
          case 'subtype':
            subtype = chatQuestion.userResponse!;
            break;
          case 'activity':
            activity = chatQuestion.userResponse!;
            break;
          case 'activityRole':
            activityRole = chatQuestion.userResponse!;
            break;
          case 'activityLevel':
            activityLevel = chatQuestion.userResponse;
            break;
          case 'professionActivities':
            professionActivities = chatQuestion.userResponse!.split(';');
            break;
          case 'peopleAffected':
            peopleAffected = chatQuestion.userResponse;
            break;
          case 'organization':
            organization = chatQuestion.userResponse;
            break;
          case 'startDate':
            startDate =
                Timestamp.fromDate(DateTime.parse(chatQuestion.userResponse!));
            break;
          case 'endDate':
            endDate = chatQuestion.userResponse != null
                ? Timestamp.fromDate(DateTime.parse(chatQuestion.userResponse!))
                : null;
            break;
          case 'location':
            location = chatQuestion.userResponse!;
            break;
          case 'workType':
            workType = chatQuestion.userResponse!;
            break;
          case 'context':
            experienceContext = chatQuestion.userResponse!;
            break;
          case 'contextPlace':
            experienceContextPlace = chatQuestion.userResponse!;
            break;
        }
      }
    });

    sendBasicAnalyticsEvent(context, "enreda_app_updated_cv");

    await database.addExperience(Experience(
        userId: auth.currentUser!.uid,
        type: type,
        subtype: subtype,
        activity: activity,
        activityRole: activityRole,
        activityLevel: activityLevel,
        professionActivities: professionActivities,
        peopleAffected: peopleAffected,
        organization: organization,
        startDate: startDate,
        endDate: endDate,
        location: location,
        workType: workType,
        context: experienceContext,
        contextPlace: experienceContextPlace));

    showCompetencies(context, userCompetencies: userCompetencies,
        onDismiss: (dialogContext) {
      Navigator.of(dialogContext).pop();

      String gamificationFlagName = "";

      switch (type) {
        case 'Formativa':
          gamificationFlagName = UserEnreda.FLAG_CV_FORMATION;
          break;
        case 'Complementaria':
          gamificationFlagName = UserEnreda.FLAG_CV_COMPLEMENTARY_FORMATION;
          break;
        case 'Personal':
          gamificationFlagName = UserEnreda.FLAG_CV_PERSONAL;
          break;
        case 'Profesional':
          gamificationFlagName = UserEnreda.FLAG_CV_PROFESSIONAL;
          break;
        default:
          break;
      }

      widget.onClose(true, gamificationFlagName);
    });
  }
}
