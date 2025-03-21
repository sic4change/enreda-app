import 'package:enreda_app/app/home/cupertino_scaffold.dart';
import 'package:enreda_app/app/sign_in/email_sign_in_change_model.dart';
import 'package:enreda_app/app/sign_up/unemployedUser/unemployed_registering.dart';
import 'package:enreda_app/common_widgets/card_access.dart';
import 'package:enreda_app/common_widgets/show_alert_dialog.dart';
import 'package:enreda_app/common_widgets/show_exception_alert_dialog.dart';
import 'package:enreda_app/common_widgets/spaces.dart';
import 'package:enreda_app/services/auth.dart';
import 'package:enreda_app/utils/const.dart';
import 'package:enreda_app/values/strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class EmailSignInFormChangeNotifier extends StatefulWidget {
  final EmailSignInChangeModel model;

  EmailSignInFormChangeNotifier({required this.model});

  @override
  _EmailSignInFormChangeNotifierState createState() =>
      _EmailSignInFormChangeNotifierState();

  static Widget create(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    return ChangeNotifierProvider<EmailSignInChangeModel>(
      create: (_) => EmailSignInChangeModel(auth: auth),
      child: Consumer<EmailSignInChangeModel>(
        builder: (_, model, __) => EmailSignInFormChangeNotifier(model: model),
      ),
    );
  }
}

class _EmailSignInFormChangeNotifierState
    extends State<EmailSignInFormChangeNotifier> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  EmailSignInChangeModel get model => widget.model;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  List<Widget> _buildChildren(BuildContext context) {
    return [
      _buildEmailTextField(),
      SizedBox(
        height: 16.0,
      ),
      _buildPasswordTextField(),
      SpaceH20(),
      Center(
        child: TextButton(
          onPressed: model.canSubmit ? _submit : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 16.0, horizontal: 48.0),
            child: Text(
              StringConst.ACCESS.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Constants.white,
              ),
            ),
          ),
          style: ButtonStyle(
              backgroundColor:
              MaterialStateProperty.all(Constants.turquoise),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ))),
        ),
      ),
      SpaceH12(),
      _buildForgotPassword(context),
      SizedBox(
        height: 32.0,
      ),
      _buildCreateAccount(context),
      SizedBox(
        height: 8.0,
      ),
    ];
  }

  TextField _buildEmailTextField() {
    return TextField(
      controller: _emailController,
      focusNode: _emailFocusNode,
      cursorColor: Constants.turquoise,
      decoration: InputDecoration(
        labelText: 'Correo electrónico',
        hintText: 'email@email.com',
        errorText: model.emailErrorText,
        enabled: model.isLoading == false,
        border: OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: const BorderSide(color: Constants.turquoise, width: 1.0),
        ),
        floatingLabelStyle: TextStyle(color: Constants.turquoise),
      ),
      autocorrect: false,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onChanged: model.updateEmail,
      onEditingComplete: () => _emailEditingComplete(),
    );
  }

  TextField _buildPasswordTextField() {
    return TextField(
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      cursorColor: Constants.turquoise,
      decoration: InputDecoration(
        labelText: 'Contraseña',
        errorText: model.passwordErrorText,
        enabled: model.isLoading == false,
        border: OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: const BorderSide(color: Constants.turquoise, width: 1.0),
        ),
        floatingLabelStyle: TextStyle(color: Constants.turquoise),
      ),
      obscureText: true,
      textInputAction: TextInputAction.done,
      onChanged: model.updatePassword,
      onEditingComplete: _submit,
    );
  }

  void _launchForgotPassword(BuildContext context) {
    if (_emailController.value.text.isNotEmpty &&
        RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(_emailController.value.text)) {
      _confirmChangePassword(context);
    } else {
      _showMessageNotChangePassword(context);
    }
  }

  Widget _buildForgotPassword(BuildContext context) {
    return InkWell(
      mouseCursor: MaterialStateMouseCursor.clickable,
      onTap: () => _launchForgotPassword(context),
      child: Center(child: Text("¿Has olvidado la contraseña?")),
    );
  }

  void _unemployedRegistering(BuildContext context) {
    Navigator.of(this.context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: ((context) => UnemployedRegistering()),
      ),
    );
  }

  Widget _buildCreateAccount(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('¿Aún no tienes cuenta?', style: TextStyle(
            fontWeight: FontWeight.bold,),),
        SpaceW8(),
        InkWell(
          mouseCursor: MaterialStateMouseCursor.clickable,
          onTap: () => _unemployedRegistering(context),
          child: Center(
              child: Text(
                "Regístrate",
                style: TextStyle(color: Constants.turquoise, fontWeight: FontWeight.bold),
              )),
        ),
      ],
    );
  }

  void _emailEditingComplete() {
    final newFocus = model.emailValidator.isValid(model.email)
        ? _passwordFocusNode
        : _emailFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  Future<void> _submit() async {
    try {
      await model.submit();
      CupertinoScaffold.controller.index = 3;
      context.canPop() ? context.pop() : context.go(StringConst.PATH_HOME);
    } on FirebaseAuthException catch (e) {
      showExceptionAlertDialog(
        context,
        title: 'Error',
        exception: e,
      );
    }
  }

  Future<void> _changePassword(BuildContext context) async {
    try {
      final auth = Provider.of<AuthBase>(context, listen: false);
      await auth.changePasswordWithEmail(_emailController.value.text);
      _emailController.clear();
      _passwordController.clear();
    } catch (e) {
      print(e);
    }
  }

  Future<void> _confirmChangePassword(BuildContext context) async {
    final didRequestSignOut = await showAlertDialog(context,
        title: 'Cambiar contraseña',
        content: 'Si pulsa en Aceptar se le envirá a su correo las acciones a '
            'realizar para cambiar su contraseña. Si no aparece, revisa las carpetas de SPAM y Correo no deseado',
        cancelActionText: 'Cancelar',
        defaultActionText: 'Aceptar');
    if (didRequestSignOut == true) {
      _changePassword(context);
    }
  }

  Future<void> _showMessageNotChangePassword(BuildContext context) async {
    showAlertDialog(
      context,
      title: 'Cambiar contraseña',
      content: 'Debes introducir un correo electrónico válido',
      defaultActionText: 'Ok',
    );
  }

  void _toggleFormType() {
    model.toggleFormType();
    _emailController.clear();
    _passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: _buildChildren(context),
    );
  }
}
