import 'dart:async';

import 'package:flutter/material.dart';

//import 'strings/base_strings.dart';
import 'util.dart';

abstract class LoadingDialogState {

  static final LoadingDialogState prompt = _LoadingDialogPromptState();
  static final LoadingDialogState loading = _LoadingDialogLoadingState();
  static final LoadingDialogState error = _LoadingDialogErrorState();
  static final LoadingDialogState success = _LoadingDialogSuccessState();

  Widget buildTitle(BuildContext context, LoadingDialog widget) => Center(child: Text(widget.title, textAlign: TextAlign.center));
  Widget buildBody(BuildContext context, LoadingDialog widget);
  List<Widget> buildActions(BuildContext context, LoadingDialog widget) => [];

  final Widget? promptContent, successContent;
  final String? title;
  final String? promptMessage, loadingMessage, errorMessage, successMessage, promptPositiveText, promptNegativeText, promptNeutralText;

  LoadingDialogState({this.promptContent, this.successContent, this.title, this.promptMessage, this.loadingMessage, this.errorMessage, this.successMessage, this.promptPositiveText, this.promptNegativeText, this.promptNeutralText});
  LoadingDialogState copyWith({ promptContent, successContent, title, promptMessage, loadingMessage, errorMessage, successMessage, promptPositiveText, promptNegativeText, promptNeutralText });
}

class LoadingDialogStateNotifier extends Notifier<LoadingDialogState> {}
typedef Listener<T> = void Function(T value);
class Notifier<T> {
  List<void Function(T value)>? _listeners;

  void listen(Listener<T> listener) => _listeners = (_listeners ?? <void Function(T value)>[])..add(listener);
  void notify(T value) => _listeners?.forEach((l) => l(value));
  void clearListeners() => _listeners?.clear();
}

class LoadingDialog extends StatefulWidget {
  final LoadingDialogState initialState;
  final LoadingDialogStateNotifier notifier;

  final void Function(BuildContext context)? initialAction, promptPositiveAction, promptNegativeAction, promptNeutralAction, successPositiveAction, errorPositiveAction, errorNegativeAction;
  final Widget? promptContent, successContent;
  final String title;
  final String? promptMessage, loadingMessage, errorMessage, successMessage, promptPositiveText, promptNegativeText, promptNeutralText, errorPositiveText, errorNegativeText;
  final bool hasErrorCustomActions;

  final bool shouldNavigateBackOnSuccess;
  final bool shouldClearNavigationOnSuccess;

  const LoadingDialog({
    Key? key,
    required this.initialState,
    required this.notifier,
    required this.title,

    this.promptContent,
    this.promptMessage,
    this.loadingMessage,
    this.errorMessage,
    this.successContent,
    this.successMessage,
    this.errorNegativeText,
    this.errorPositiveText,
    this.promptNegativeText,
    this.promptPositiveText,
    this.promptNeutralText,

    this.initialAction,
    this.promptNegativeAction,
    this.promptPositiveAction,
    this.errorNegativeAction,
    this.errorPositiveAction,
    this.promptNeutralAction,
    this.successPositiveAction,
    this.shouldNavigateBackOnSuccess = false,
    this.shouldClearNavigationOnSuccess = false,
    this.hasErrorCustomActions = false,
  }) : assert (promptPositiveAction != null || initialAction != null, 'Either promptPositiveAction or initialAction should be present'), super(key: key);

  @override
  State<LoadingDialog> createState() => _LoadingDialogState();

  FutureOr<void> show(BuildContext context){
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (c) => WillPopScope(onWillPop: () async => false, child: this)
    );
  }
}

class _LoadingDialogState extends State<LoadingDialog> {

  late LoadingDialogState state;
  bool isInitialActionInvoked = false;

  @override
  void initState() {
    state = widget.initialState;
    widget.notifier.listen((s) => setState(() => state = s));
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (!isInitialActionInvoked) {
      setState(() {
        isInitialActionInvoked = true;
        widget.initialAction?.call(context);
      });
    }
    super.didChangeDependencies();
  }


  @override
  void dispose() {
    widget.notifier.clearListeners();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: state.buildTitle(context, widget),
      content: SingleChildScrollView( // Para adaptarse a contenido variable
        child: state.buildBody(context, widget),
      ),
      actions: state.buildActions(context, widget),
    );
  }

}

class _LoadingDialogPromptState extends LoadingDialogState {

  _LoadingDialogPromptState({super.promptContent, super.successContent, super.title, super.promptMessage, super.loadingMessage, super.errorMessage, super.successMessage, super.promptPositiveText, super.promptNegativeText, super.promptNeutralText});
  @override LoadingDialogState copyWith({ promptContent, successContent, title, promptMessage, loadingMessage, errorMessage, successMessage, promptPositiveText, promptNegativeText, promptNeutralText }) => _LoadingDialogPromptState(
      promptContent: promptContent,
      successContent: successContent,
      title: title,
      promptMessage: promptMessage,
      loadingMessage: loadingMessage,
      errorMessage: errorMessage,
      successMessage: successMessage,
      promptPositiveText: promptPositiveText,
      promptNegativeText: promptNegativeText,
      promptNeutralText: promptNeutralText);

  @override
  Widget buildBody(BuildContext context, LoadingDialog widget) => widget.promptContent ?? Text(promptMessage ?? widget.promptMessage!, textAlign: TextAlign.center);

  @override
  List<Widget> buildActions(BuildContext context, LoadingDialog widget) {
    var negativeAction = widget.promptNegativeAction ?? (c) => goBack(c);
   // var strings = getStrings(context);
    return [
      TextButton(onPressed: () => negativeAction(context), child: Text(widget.promptNegativeText ?? "strings.cancel")),
      if((promptNeutralText ?? widget.promptNeutralText) != null) TextButton(onPressed: () => widget.promptNeutralAction?.call(context), child: Text(promptNeutralText ?? widget.promptNeutralText!)),
      TextButton(onPressed: () => widget.promptPositiveAction?.call(context), child: Text(widget.promptPositiveText ?? "strings.ok")),
    ];
  }
}

class _LoadingDialogLoadingState extends LoadingDialogState {

  _LoadingDialogLoadingState({super.promptContent, super.successContent, super.title, super.promptMessage, super.loadingMessage, super.errorMessage, super.successMessage, super.promptPositiveText, super.promptNegativeText, super.promptNeutralText});
  @override LoadingDialogState copyWith({ promptContent, successContent, title, promptMessage, loadingMessage, errorMessage, successMessage, promptPositiveText, promptNegativeText, promptNeutralText }) => _LoadingDialogLoadingState(
      promptContent: promptContent,
      successContent: successContent,
      title: title,
      promptMessage: promptMessage,
      loadingMessage: loadingMessage,
      errorMessage: errorMessage,
      successMessage: successMessage,
      promptPositiveText: promptPositiveText,
      promptNegativeText: promptNegativeText,
      promptNeutralText: promptNeutralText);

  @override
  Widget buildTitle(BuildContext context, LoadingDialog widget) {
    return Row(
      children: [
        Expanded(child: Text(widget.title, textAlign: TextAlign.center)),
        InkWell(
            onTap: () => widget.notifier.notify(LoadingDialogState.error.copyWith(errorMessage: "getStrings(context).actionCancelled")),
            child: const Icon(Icons.close)
        ),
      ],
    );
  }

  @override
  @override
  Widget buildBody(BuildContext context, LoadingDialog widget) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Ajuste de tamaño automático
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: const CircularProgressIndicator(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(widget.loadingMessage!, textAlign: TextAlign.center),
        ),
      ],
    );
  }

}

class _LoadingDialogErrorState extends LoadingDialogState {

  _LoadingDialogErrorState({super.promptContent, super.successContent, super.title, super.promptMessage, super.loadingMessage, super.errorMessage, super.successMessage, super.promptPositiveText, super.promptNegativeText, super.promptNeutralText});
  @override LoadingDialogState copyWith({ promptContent, successContent, title, promptMessage, loadingMessage, errorMessage, successMessage, promptPositiveText, promptNegativeText, promptNeutralText }) => _LoadingDialogErrorState(
      promptContent: promptContent,
      successContent: successContent,
      title: title,
      promptMessage: promptMessage,
      loadingMessage: loadingMessage,
      errorMessage: errorMessage,
      successMessage: successMessage,
      promptPositiveText: promptPositiveText,
      promptNegativeText: promptNegativeText,
      promptNeutralText: promptNeutralText);

  @override
  Widget buildBody(BuildContext context, LoadingDialog widget) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Ajuste automático del tamaño
      children: [
        Text(errorMessage ?? widget.errorMessage!, textAlign: TextAlign.center),
      ],
    );
  }
  @override
  List<Widget> buildActions(BuildContext context, LoadingDialog widget) {
   // var strings = getStrings(context);
    var defaultNegativeAction = widget.errorNegativeAction ?? (c) => goBack(c);
    var defaultPositiveAction = widget.errorPositiveAction ?? (c) => goBack(c);

    return widget.hasErrorCustomActions
        ? [
      if (widget.errorNegativeText != null) TextButton(onPressed: () => defaultNegativeAction(context), child: Text(widget.errorNegativeText!)),
      if (widget.errorPositiveText != null) TextButton(onPressed: () => defaultPositiveAction(context), child: Text(widget.errorPositiveText!)),
    ]
        :[
      TextButton(onPressed: () => defaultNegativeAction(context), child: Text(widget.errorNegativeText ?? "strings.cancel")),
      TextButton(onPressed: () => widget.errorPositiveAction?.call(context), child: Text(widget.errorPositiveText ?? "strings.retry")),
    ];
  }
}

class _LoadingDialogSuccessState extends LoadingDialogState {
  _LoadingDialogSuccessState({super.promptContent, super.successContent, super.title, super.promptMessage, super.loadingMessage, super.errorMessage, super.successMessage, super.promptPositiveText, super.promptNegativeText, super.promptNeutralText});

  @override LoadingDialogState copyWith({ promptContent, successContent, title, promptMessage, loadingMessage, errorMessage, successMessage, promptPositiveText, promptNegativeText, promptNeutralText }) => _LoadingDialogSuccessState(
      promptContent: promptContent,
      successContent: successContent,
      title: title,
      promptMessage: promptMessage,
      loadingMessage: loadingMessage,
      errorMessage: errorMessage,
      successMessage: successMessage,
      promptPositiveText: promptPositiveText,
      promptNegativeText: promptNegativeText,
      promptNeutralText: promptNeutralText);

  @override
  Widget buildBody(BuildContext context, LoadingDialog widget) {
    return successContent ?? widget.successContent ?? Text(widget.successMessage!, textAlign: TextAlign.center);
  }

  @override
  List<Widget> buildActions(BuildContext context, LoadingDialog widget) {
    var onPressed = widget.successPositiveAction ?? (c) {
      goBack(c);
      if (widget.shouldNavigateBackOnSuccess) goBack(c);
      if (widget.shouldClearNavigationOnSuccess) clearNavigation(c);
    };
    return [ TextButton(child: Text("getStrings(context).ok"), onPressed: () => onPressed(context)),];
  }
}
