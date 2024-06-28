import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enreda_app/app/home/assistant/simple_text_style.dart';
import 'package:enreda_app/app/home/models/chatQuestion.dart';
import 'package:enreda_app/app/home/models/choice.dart';
import 'package:enreda_app/app/home/models/experience.dart';
import 'package:enreda_app/app/home/models/question.dart';
import 'package:enreda_app/app/home/assistant/list_item_builder.dart';
import 'package:enreda_app/app/home/models/userEnreda.dart';
import 'package:enreda_app/common_widgets/custom_text.dart';
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

class AssistantPageMobile extends StatefulWidget {
  const AssistantPageMobile({Key? key, required this.onFinish}) : super(key: key);

  final void Function(String gamificationFlagName) onFinish;

  @override
  _AssistantPageMobileState createState() => _AssistantPageMobileState();
}

class _AssistantPageMobileState extends State<AssistantPageMobile> {
  TextEditingController messageEditingController = new TextEditingController();
  List<Question> questions = [];
  List<ChatQuestion> chatQuestions = [];
  ValueNotifier<List<Choice>> currentChoicesNotifier =
      ValueNotifier<List<Choice>>([]);
  ValueNotifier<List<Choice>> sourceAutoCompleteNotifier =  ValueNotifier<List<Choice>>([]);
  List<List<Choice>> choicesLog = [];
  ValueNotifier<bool> isWritingNotifier = ValueNotifier<bool>(false);
  ValueNotifier<bool> isTextEnabledNotifier = ValueNotifier<bool>(false);
  late ChatQuestion _currentChatQuestion;

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
    messageEditingController.dispose();
    MessageTile.experienceTypeId = null;
    MessageTile.experienceSubtypeId = null;
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
            //TODO: Esto lo activamos si queremos que se refresque todo el chat cuando cambien de pestaña y vuelvan
            return /* VisibilityDetector(
              key: Key('visibility_detector_key'),
              onVisibilityChanged: (visibilityInfo) {
                var visiblePercentage = visibilityInfo.visibleFraction * 100;
                if (visiblePercentage > 50) {
                  _resetQuestions();
                }
              },
              child:*/ SafeArea(
                child: Container(
                  decoration: BoxDecoration(
                    color: Constants.white,
                  ),
                  clipBehavior: Clip.hardEdge,
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
                            SpaceW12(),
                            CustomTextMediumBold(text: StringConst.CHAT_TITLE, color: Colors.white,),
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
              //),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
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
    TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      height: 60.0,
      color: AppColors.primary050,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
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
                        icon: Icon(Icons.arrow_back),
                        color: AppColors.primary500,
                        onPressed: () => isWriting ? {} : _editLastResponse(),
                      ));
                }),
            ValueListenableBuilder<bool>(
                valueListenable: isTextEnabledNotifier,
                builder: (context, isTextEnabled, child) {
                  return Expanded(
                      child: TextField(
                    enabled: isTextEnabled,
                    controller: messageEditingController,
                    style: simpleTextStyle(),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(10.0, 1.0, 5.0, 10.0),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        hintText: 'Escribe algo...',
                        hintStyle: textTheme.bodySmall?.copyWith(
                          color: AppColors.primaryText1,
                          height: 1.5,
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                    ),
                  ));
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
                            showAlertDialog(
                              this.context,
                              title: StringConst.CHAT_TITLE_QUESTION,
                              content: StringConst.CHAT_CONTENT_QUESTION,
                              defaultActionText: StringConst.FORM_ACCEPT,
                            );
                            return;
                          }

                          if (question.type == StringConst.TEXT_QUESTION &&
                              messageEditingController.text.isEmpty) {
                            showAlertDialog(
                              this.context,
                              title: StringConst.CHAT_TITLE_QUESTION,
                              content: StringConst.CHAT_ANSWER_QUESTION,
                              defaultActionText: StringConst.FORM_ACCEPT,
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
                              defaultActionText: StringConst.FORM_ACCEPT,
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
      ),
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
      isTextEnabledNotifier.value = true;
    } else {
      isTextEnabledNotifier.value = false;
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
      if (question.order == 1 || question.order == 2 || question.order == 3)
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
      isTextEnabledNotifier.value = true;
    } else {
      isTextEnabledNotifier.value = false;
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

    if (_currentQuestion.type == StringConst.NONE_QUESTION) {
      _editLastResponse();
    }
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

    sendBasicAnalyticsEvent(context, "enreda_app_updated_cv");

    //_resetQuestions();
    showCompetencies(context, userCompetencies: userCompetencies,
        onDismiss: (dialogContext) {
      Navigator.of(dialogContext).pop();
      _resetQuestions();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(StringConst.EXPERIENCE_ADDED),
      ));
      // show Gamification snackbar
      switch (type) {
        case 'Formativa':
          widget.onFinish(UserEnreda.FLAG_CV_FORMATION);
          break;
        case 'Complementaria':
          widget.onFinish(UserEnreda.FLAG_CV_COMPLEMENTARY_FORMATION);
          break;
        case 'Personal':
          widget.onFinish(UserEnreda.FLAG_CV_PERSONAL);
          break;
        case 'Profesional':
          widget.onFinish(UserEnreda.FLAG_CV_PROFESSIONAL);
          break;
        default:
          widget.onFinish("");
          break;
      }
    });
  }
}
