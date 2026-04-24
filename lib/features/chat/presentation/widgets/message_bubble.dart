/// Один элемент ленты сообщений.
///
/// Дизайн без «пузырей» (как у Claude): аватар слева + контент справа.
/// Для сообщений ассистента парсятся inline-сноски `[1][2][3]`, рендерятся
/// чипы источников и статус-чип (RAG найден / не найден / общий / вне темы).
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../../app/theme.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../domain/entities/chat_entities.dart';

/// Callback открытия панели источника.
/// index — номер сноски (1-based), sources — список источников сообщения.
typedef OnSourceTap = void Function(int index, List<Source> sources);

class MessageBubble extends StatelessWidget {
  final Message message;
  final OnSourceTap? onSourceTap;

  const MessageBubble({super.key, required this.message, this.onSourceTap});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl, vertical: AppSpacing.md,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Avatar(isUser: isUser),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SenderName(isUser: isUser),
                    const SizedBox(height: 6),
                    if (isUser)
                      _UserBody(text: message.content)
                    else
                      _AiBody(
                        content: message.content,
                        sources: message.sources,
                        onSourceTap: onSourceTap,
                      ),
                    if (!isUser &&
                        message.sources != null &&
                        message.sources!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      _SourceChips(
                        sources: message.sources!,
                        onTap: onSourceTap,
                      ),
                    ],
                    if (!isUser) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _MessageActions(message: message),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────── Avatar ───────────────────────

class _Avatar extends StatelessWidget {
  final bool isUser;
  const _Avatar({required this.isUser});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userColor =
        isDark ? AppColorsDark.userAvatar : AppColorsLight.userAvatar;

    if (isUser) {
      return Container(
        width: 30, height: 30,
        decoration: BoxDecoration(
          color: userColor,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        alignment: Alignment.center,
        child: const Text(
          'Вы',
          style: TextStyle(
            fontFamily: AppFonts.ui,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      );
    }

    return Container(
      width: 30, height: 30,
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      alignment: Alignment.center,
      child: const AppLogo(size: 18, monochrome: true),
    );
  }
}

class _SenderName extends StatelessWidget {
  final bool isUser;
  const _SenderName({required this.isUser});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Text(
      isUser ? 'Вы' : 'Ассистент',
      style: TextStyle(
        fontFamily: AppFonts.display,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: colors.onSurface,
      ),
    );
  }
}

// ─────────────────────── Body: user ───────────────────────

class _UserBody extends StatelessWidget {
  final String text;
  const _UserBody({required this.text});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SelectableText(
      text,
      style: TextStyle(
        fontFamily: AppFonts.ui,
        fontSize: 15, height: 1.65,
        color: colors.onSurface,
      ),
    );
  }
}

// ─────────────────────── Body: AI (с inline-сносками) ───────────────────────

class _AiBody extends StatelessWidget {
  final String content;
  final List<Source>? sources;
  final OnSourceTap? onSourceTap;
  const _AiBody({
    required this.content,
    required this.sources,
    required this.onSourceTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bodyStyle = TextStyle(
      fontFamily: AppFonts.ui,
      fontSize: 15, height: 1.65,
      color: colors.onSurface,
    );

    // Если нет источников — рендерим как markdown (сохраняем списки, код и т.п.).
    // Иначе разбиваем текст по `[N]` и делаем из них кликабельные сноски.
    if (sources == null || sources!.isEmpty) {
      return MarkdownBody(
        data: content,
        selectable: true,
        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
          p: bodyStyle,
          code: TextStyle(
            fontFamily: AppFonts.mono, fontSize: 13,
            backgroundColor: colors.surfaceContainerHighest,
          ),
          codeblockDecoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      );
    }

    return SelectableText.rich(
      _buildInline(context, content, sources!, bodyStyle),
      style: bodyStyle,
    );
  }

  TextSpan _buildInline(
    BuildContext context,
    String text,
    List<Source> srcs,
    TextStyle base,
  ) {
    final regex = RegExp(r'\[(\d+)\]');
    final spans = <InlineSpan>[];

    int pos = 0;
    for (final m in regex.allMatches(text)) {
      if (m.start > pos) {
        spans.add(TextSpan(text: text.substring(pos, m.start), style: base));
      }
      final index = int.tryParse(m.group(1) ?? '') ?? 0;
      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: _FootnoteChip(
          index: index,
          onTap: () => onSourceTap?.call(index, srcs),
        ),
      ));
      pos = m.end;
    }
    if (pos < text.length) {
      spans.add(TextSpan(text: text.substring(pos), style: base));
    }
    return TextSpan(children: spans);
  }
}

/// Кликабельная inline-сноска `[N]` в теле ответа ассистента.
class _FootnoteChip extends StatelessWidget {
  final int index;
  final VoidCallback? onTap;
  const _FootnoteChip({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentBg =
        isDark ? AppColorsDark.accentBg : AppColorsLight.accentBg;
    final accent = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 18, height: 18,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: accentBg,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '$index',
            style: TextStyle(
              fontFamily: AppFonts.ui,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────── Source chips ───────────────────────

class _SourceChips extends StatelessWidget {
  final List<Source> sources;
  final OnSourceTap? onTap;
  const _SourceChips({required this.sources, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6, runSpacing: 6,
      children: [
        for (var i = 0; i < sources.length; i++)
          _SourceChip(
            index: i + 1,
            source: sources[i],
            onTap: () => onTap?.call(i + 1, sources),
          ),
      ],
    );
  }
}

class _SourceChip extends StatefulWidget {
  final int index;
  final Source source;
  final VoidCallback onTap;
  const _SourceChip({
    required this.index,
    required this.source,
    required this.onTap,
  });

  @override
  State<_SourceChip> createState() => _SourceChipState();
}

class _SourceChipState extends State<_SourceChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceAlt =
        isDark ? AppColorsDark.surfaceAlt : AppColorsLight.surfaceAlt;
    final border = isDark ? AppColorsDark.border : AppColorsLight.border;
    final accentBg =
        isDark ? AppColorsDark.accentBg : AppColorsLight.accentBg;
    final accent = Theme.of(context).colorScheme.primary;
    final text = isDark ? AppColorsDark.text : AppColorsLight.text;
    final muted = isDark ? AppColorsDark.textMuted : AppColorsLight.textMuted;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.fromLTRB(8, 5, 10, 5),
          decoration: BoxDecoration(
            color: surfaceAlt,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(color: _hovered ? accent : border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16, height: 16,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accentBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${widget.index}',
                  style: TextStyle(
                    fontFamily: AppFonts.ui, fontSize: 10,
                    fontWeight: FontWeight.w700, color: accent,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 200),
                child: Text(
                  widget.source.documentName,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppFonts.ui, fontSize: 12,
                    color: _hovered ? text : muted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────── Actions: status chip + copy ───────────────────────

class _MessageActions extends StatefulWidget {
  final Message message;
  const _MessageActions({required this.message});

  @override
  State<_MessageActions> createState() => _MessageActionsState();
}

class _MessageActionsState extends State<_MessageActions> {
  bool _copied = false;

  Future<void> _onCopy() async {
    await Clipboard.setData(ClipboardData(text: widget.message.content));
    if (!mounted) return;
    setState(() => _copied = true);
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (widget.message.sourceType != null) ...[
          SourceTypeChip(type: widget.message.sourceType!),
          const SizedBox(width: AppSpacing.md),
        ],
        _CopyButton(copied: _copied, onTap: _onCopy),
      ],
    );
  }
}

class _CopyButton extends StatelessWidget {
  final bool copied;
  final VoidCallback onTap;
  const _CopyButton({required this.copied, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dim = isDark ? AppColorsDark.textDim : AppColorsLight.textDim;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(copied ? Icons.check : Icons.content_copy_outlined,
              size: 13, color: dim),
          const SizedBox(width: 5),
          Text(
            copied ? 'Скопировано' : 'Копировать',
            style: TextStyle(
              fontFamily: AppFonts.ui, fontSize: 11.5, color: dim,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────── SourceTypeChip ───────────────────────

/// Чип типа источника ответа: 4 состояния (ragFound / ragNotFound /
/// noRag / offTopic). Использует цвета из темы (success / warning /
/// textMuted / danger).
class SourceTypeChip extends StatelessWidget {
  final SourceType type;
  const SourceTypeChip({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (label, icon, color) = _resolve(isDark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppFonts.ui, fontSize: 11,
              fontWeight: FontWeight.w500, color: color,
            ),
          ),
        ],
      ),
    );
  }

  (String, IconData, Color) _resolve(bool isDark) {
    switch (type) {
      case SourceType.ragFound:
        return (
          'Источники найдены',
          Icons.check_circle_outline,
          isDark ? AppColorsDark.success : AppColorsLight.success,
        );
      case SourceType.ragNotFound:
        return (
          'В базе не найдено',
          Icons.info_outline,
          isDark ? AppColorsDark.warning : AppColorsLight.warning,
        );
      case SourceType.noRag:
        return (
          'Общий ответ',
          Icons.auto_awesome,
          isDark ? AppColorsDark.textMuted : AppColorsLight.textMuted,
        );
      case SourceType.offTopic:
        return (
          'Вне тематики',
          Icons.explore_off_outlined,
          isDark ? AppColorsDark.danger : AppColorsLight.danger,
        );
    }
  }
}
