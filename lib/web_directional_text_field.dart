library web_directional_text_field;

// ignore_for_file: prefer_const_constructors, avoid_web_libraries_in_flutter, file_names

import 'dart:async';
import 'dart:html';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final Map<ShortcutActivator, Intent> scrollShortcutOverrides = kIsWeb
    ? <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.space):
            DoNothingAndStopPropagationIntent(),
        SingleActivator(LogicalKeyboardKey.arrowUp):
            DoNothingAndStopPropagationIntent(),
        SingleActivator(LogicalKeyboardKey.arrowDown):
            DoNothingAndStopPropagationIntent(),
        SingleActivator(LogicalKeyboardKey.arrowLeft):
            DoNothingAndStopPropagationIntent(),
        SingleActivator(LogicalKeyboardKey.arrowRight):
            DoNothingAndStopPropagationIntent(),
        SingleActivator(LogicalKeyboardKey.tab):
            DoNothingAndStopPropagationIntent(),
      }
    : <LogicalKeySet, Intent>{};

class WebTextField extends StatefulWidget {
  static final Map<int, InputElement> _elements = {};

  static void initialize() {
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory('input', (int viewId) {
      var e = InputElement();
      e.style.border = "none";
      e.style.outline = "none";
      e.style.backgroundColor = "transparent";
      e.dir = "auto";
      e.style.height = "100%";
      e.style.width = "100%";
      _elements[viewId] = e;
      return e;
    });
  }

  const WebTextField({
    Key? key,
    this.onChanged,
    this.style,
    this.textAlign,
    this.textAlignVertical,
    this.expands = false,
    this.cursorColor,
    this.selectionColor,
    this.decoration,
    this.cssValues,
    this.controller,
    this.initialValue,
    this.inputFontSize = 16,
    this.obscureText = false,
    this.textDirection = TextFieldDirection.auto,
  }) : super(key: key);

  final TextFieldDirection textDirection;
  final String? initialValue;
  final Function(String)? onChanged;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextAlignVertical? textAlignVertical;
  final bool expands;
  final int inputFontSize;
  final Color? cursorColor;
  final Color? selectionColor;
  final InputDecoration? decoration;
  final Map<String, String>? cssValues;
  final TextEditingController? controller;
  final bool obscureText;

  @override
  State<WebTextField> createState() => _WebTextFieldState();
}

enum TextFieldDirection { rtl, ltr, auto }

class _WebTextFieldState extends State<WebTextField> {
  int? id;
  FocusNode focusNode = FocusNode();

  late TextEditingController _controller;
  late String value;
  bool _isHovering = false;

  bool pressed = false;
  static StreamController<_WebTextFieldState> pressedId =
      StreamController.broadcast();
  StreamSubscription? s;

  @override
  void initState() {
    _controller =
        widget.controller ?? TextEditingController(text: widget.initialValue);
    value = _controller.text;
    focusNode.addListener(onFocusChanged);
    s = pressedId.stream.listen((event) {
      setState(() {
        if (event == this) {
          pressed = true;
        } else {
          pressed = false;
        }
      });
    });
    super.initState();
  }

  void _handleHover(bool hovering) {
    if (hovering != _isHovering) {
      setState(() {
        _isHovering = hovering;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle s = widget.style ?? Theme.of(context).textTheme.subtitle1!;
    return GestureDetector(
      onTap: () {
        setState(() {
          pressedId.add(this);
        });
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.text,
        onEnter: (PointerEnterEvent event) => _handleHover(true),
        onExit: (PointerExitEvent event) => _handleHover(false),
        child: Shortcuts(
          shortcuts: scrollShortcutOverrides,
          child: AnimatedBuilder(
            animation: focusNode,
            builder: (BuildContext context, Widget? child) {
              TextDirection t = ui.TextDirection.rtl;
              switch (widget.textDirection) {
                case TextFieldDirection.ltr:
                  t = ui.TextDirection.ltr;
                  break;
                case TextFieldDirection.rtl:
                  t = ui.TextDirection.rtl;
                  break;
                case TextFieldDirection.auto:
                  t = ui.TextDirection.ltr;
                  break;
                default:
              }
              return Focus(
                focusNode: focusNode,
                child: SizedBox(
                  child: InputDecorator(
                    decoration: widget.decoration ?? InputDecoration(),
                    baseStyle: widget.style,
                    textAlign: widget.textAlign,
                    textAlignVertical: widget.textAlignVertical,
                    isFocused: focusNode.hasFocus,
                    isEmpty: value.isEmpty,
                    expands: widget.expands,
                    isHovering: _isHovering,
                    child: SizedBox(
                      height: (s.height ?? 1) * s.fontSize!,
                      child: pressed
                          ? HtmlElementView(
                              viewType: 'input',
                              onPlatformViewCreated: (i) {
                                id = i;
                                var e = WebTextField._elements[i]!;
                                e.type =
                                    widget.obscureText ? "password" : "text";
                                e.style.fontSize = "16px";
                                e.style.padding = "0px";
                                e.style.paddingBottom =
                                    "8px"; // for letters like 'g' which are under the bottom line.
                                e.dir = widget.textDirection.name;
                                e.style.font =
                                    '''${widget.inputFontSize}px "Segoe UI", Arial, sans-serif''';
                                e.defaultValue = value;
                                e.style.height = "100%";
                                var theme = Theme.of(context);
                                e.style.setProperty("caret-color",
                                    "#${(widget.cursorColor ?? theme.textSelectionTheme.cursorColor ?? Colors.lightBlue).value.toRadixString(16).substring(2)}");
                                widget.cssValues?.forEach((key, value) {
                                  e.style.setProperty(key, value);
                                });
                                e.parent!.children.add(StyleElement()
                                  ..innerHtml = '''
                            input::selection {
                              background: #${(widget.selectionColor ?? theme.textSelectionTheme.selectionColor ?? Colors.blue[200]!).value.toRadixString(16).substring(2)};
                            }
                          ''');
                                e.onInput.capture((event) {
                                  if ((e.value ?? "") != value) {
                                    value = e.value ?? "";
                                    _controller.text = e.value ?? "";
                                    widget.onChanged?.call(e.value ?? "");
                                  }
                                });
                                e.onFocus.capture((event) {
                                  focusNode.requestFocus();
                                });
                                e.onBlur.capture((event) {
                                  focusNode.unfocus();
                                });
                                _controller.addListener(onControllerChange);
                                e.selectionStart =
                                    e.selectionEnd = e.value?.length ?? 1;
                                e.focus();
                              },
                            )
                          : Text(
                              _controller.text,
                              style: widget.style?.copyWith(
                                  color: Colors.black,
                                  fontSize: widget.inputFontSize.toDouble()),
                              textAlign: widget.textAlign,
                              textDirection: t,
                            ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(onControllerChange);
    s?.cancel();
    super.dispose();
  }

  void onControllerChange() {
    if (widget.controller != null && widget.controller!.text != value) {
      value = widget.controller!.text;
      WebTextField._elements[id!]!.value = value;
    }
  }

  void onFocusChanged() {
    var e = WebTextField._elements[id!]!;
    if (focusNode.hasFocus) {
      e.focus();
    } else {
      e.blur();
    }
  }
}

class WebTextFormField extends FormField<String> {
  WebTextFormField({
    Key? key,
    this.controller,
    String? initialValue,
    FocusNode? focusNode,
    InputDecoration? decoration = const InputDecoration(),
    TextStyle? style,
    bool expands = false,
    Color? cursorColor,
    Color? selectionColor,
    ValueChanged<String>? onChanged,
    FormFieldSetter<String>? onSaved,
    FormFieldValidator<String>? validator,
    bool? enabled,
    bool obscureText = false,
    int inputFontsize = 16,
    AutovalidateMode? autovalidateMode,
    this.textDirection = TextFieldDirection.auto,
  }) : super(
          key: key,
          initialValue:
              controller != null ? controller.text : (initialValue ?? ''),
          onSaved: onSaved,
          validator: validator,
          enabled: enabled ?? decoration?.enabled ?? true,
          autovalidateMode: autovalidateMode ?? AutovalidateMode.disabled,
          builder: (FormFieldState<String> field) {
            final InputDecoration effectiveDecoration = (decoration ??
                    const InputDecoration())
                .applyDefaults(Theme.of(field.context).inputDecorationTheme);
            void onChangedHandler(String value) {
              field.didChange(value);
              if (onChanged != null) {
                onChanged(value);
              }
            }

            return WebTextField(
              controller: controller,
              initialValue: initialValue,
              decoration:
                  effectiveDecoration.copyWith(errorText: field.errorText),
              style: style,
              expands: expands,
              cursorColor: cursorColor,
              selectionColor: selectionColor,
              obscureText: obscureText,
              inputFontSize: inputFontsize,
              onChanged: onChangedHandler,
              textDirection: textDirection,
            );
          },
        );

  /// Controls the text being edited.
  ///
  /// If null, this widget will create its own [TextEditingController] and
  /// initialize its [TextEditingController.text] with [initialValue].
  final TextEditingController? controller;
  final TextFieldDirection textDirection;

  @override
  FormFieldState<String> createState() => _TextFormFieldState();
}

class _TextFormFieldState extends FormFieldState<String> {
  @override
  WebTextFormField get widget => super.widget as WebTextFormField;
}
