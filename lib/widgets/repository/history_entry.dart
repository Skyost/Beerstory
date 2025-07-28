import 'package:beerstory/i18n/translations.g.dart';
import 'package:beerstory/model/beer/beer.dart';
import 'package:beerstory/model/beer/repository.dart';
import 'package:beerstory/model/history_entry/history_entry.dart';
import 'package:beerstory/model/repository.dart';
import 'package:beerstory/spacing.dart';
import 'package:beerstory/widgets/repository/beer.dart';
import 'package:beerstory/widgets/scrollable_sheet_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart';

/// A widget that allows to display a history entry.
class HistoryEntryWidget extends ConsumerWidget {
  /// The history entry.
  final HistoryEntry historyEntry;

  /// Creates a new history entry widget.
  const HistoryEntryWidget({
    super.key,
    required this.historyEntry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Beer? beer = ref.watch(beerRepositoryProvider.select((list) => list.value?.findByUuid(historyEntry.uuid)));
    if (beer == null) {
      return SizedBox.shrink();
    }
    return FTile.raw(
      prefix: FBadge(
        child: Text('${historyEntry.times}x'),
      ),
      onPress: () => showFSheet(
        context: context,
        builder: (context) => ScrollableSheetContentWidget(
          builder: (context, scrollController) => BeerDetailsWidget(
            beerUuid: historyEntry.uuid,
            scrollController: scrollController,
          ),
        ),
        side: FLayout.btt,
        mainAxisMaxRatio: null,
      ),
      child: Row(
        children: [
          BeerWidget(object: beer),
          if (historyEntry.quantity != null)
            Padding(
              padding: const EdgeInsets.only(top: kSpace),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: translations.history.page.total,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: ' '),
                    TextSpan(
                      text: translations.history.page.quantity(
                        prefix: historyEntry.moreThanQuantity ? '+' : '',
                        quantity: NumberFormat.decimalPattern().format(historyEntry.quantity),
                      ),
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
