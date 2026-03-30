/// Поле ввода сообщения с кнопкой отправки.
///
/// Поддерживает: отправку по Enter, очистку, счётчик символов,
/// блокировку при обработке ИИ.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/validators.dart';

/// Поле ввода сообщения внизу экрана чата.
class MessageInput extends StatefulWidget {
  /// Callback при отправке сообщения
  final ValueChanged<String> onSend;

  /// Заблокировать ввод (ИИ обрабатывает предыдущий запрос)
  final bool isDisabled;

  /// Текст-подсказка в поле ввода (зависит от роли пользователя).
  /// Если не задан — используется дефолтный.
  final String? hintText;

  const MessageInput({
    super.key,
    required this.onSend,
    this.isDisabled = false,
    this.hintText,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  /// Текущая длина введённого текста (для счётчика)
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _charCount = _controller.text.length;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Можно ли отправить сообщение
  bool get _canSend =>
      !widget.isDisabled &&
      _controller.text.trim().isNotEmpty &&
      _charCount <= AppConstants.maxMessageLength;

  /// Отправить сообщение
  void _send() {
    final text = _controller.text.trim();
    // Клиентская валидация
    final error = Validators.chatMessage(text);
    if (error != null) return;

    widget.onSend(text);
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isOverLimit = _charCount > AppConstants.maxMessageLength;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(color: colors.outlineVariant.withOpacity(0.3)),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // ─── Текстовое поле ───
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    enabled: !widget.isDisabled,
                    maxLines: 5,
                    minLines: 1,
                    textInputAction: TextInputAction.newline,
                    // Отправка по Enter (без Shift)
                    onSubmitted: (_) => _send(),
                    // Перехват Enter для отправки
                    inputFormatters: [
                      // Ограничиваем максимальную длину +10% (с запасом)
                      LengthLimitingTextInputFormatter(
                        (AppConstants.maxMessageLength * 1.1).toInt(),
                      ),
                    ],
                    decoration: InputDecoration(
                      hintText: widget.isDisabled
                          ? 'Подождите, ИИ обрабатывает запрос...'
                          : (widget.hintText ?? 'Введите сообщение...'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: colors.surfaceContainerHighest,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      // Кнопка очистки
                      suffixIcon: _charCount > 0
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () {
                                _controller.clear();
                                _focusNode.requestFocus();
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // ─── Кнопка отправки ───
                IconButton.filled(
                  onPressed: _canSend ? _send : null,
                  icon: const Icon(Icons.send_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor:
                        _canSend ? colors.primary : colors.surfaceContainerHigh,
                    foregroundColor:
                        _canSend ? colors.onPrimary : colors.outline,
                  ),
                ),
              ],
            ),

            // ─── Счётчик символов (показываем когда >50% лимита) ───
            if (_charCount > AppConstants.maxMessageLength * 0.5)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '$_charCount / ${AppConstants.maxMessageLength}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isOverLimit ? colors.error : colors.outline,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
