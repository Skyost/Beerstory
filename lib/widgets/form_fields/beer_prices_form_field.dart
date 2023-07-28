import 'package:beerstory/model/bar/bar.dart';
import 'package:beerstory/model/bar/repository.dart';
import 'package:beerstory/model/beer/beer.dart';
import 'package:beerstory/utils/utils.dart';
import 'package:beerstory/widgets/large_button.dart';
import 'package:ez_localization/ez_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Allows to edit a beer prices.
class BeerPricesFormField extends FormField<List<BeerPrice>> {
  /// Creates a new beer prices form field instance.
  BeerPricesFormField({
    super.key,
    super.validator,
    super.onSaved,
    List<BeerPrice>? initialValue,
    required String noBarFoundText,
    Widget? emptyWidget,
    bool editablePrices = true,
  }) : super(
          initialValue: initialValue?.map((price) => price.copy()).toList(),
          builder: (state) => _BeerPricesFormFieldWidget(
            formState: state as _BeerPricesFormFieldState,
            noBarFoundText: noBarFoundText,
            emptyWidget: emptyWidget,
            editablePrices: editablePrices,
          ),
        );

  @override
  FormFieldState<List<BeerPrice>> createState() => _BeerPricesFormFieldState();
}

/// The beer prices form field state.
class _BeerPricesFormFieldState extends FormFieldState<List<BeerPrice>> {
  /// Wrapper for [setValue].
  void _setValue(List<BeerPrice>? value) => setValue(value);
}

/// The beer prices form field widget.
class _BeerPricesFormFieldWidget extends ConsumerWidget {
  /// The form state.
  final _BeerPricesFormFieldState formState;

  /// When no bar is found.
  final String noBarFoundText;

  /// The empty widget.
  final Widget? emptyWidget;

  /// Whether the prices are editable.
  final bool editablePrices;

  /// Creates a new beer prices form field widget.
  const _BeerPricesFormFieldWidget({
    required this.formState,
    required this.noBarFoundText,
    this.emptyWidget,
    this.editablePrices = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    BarRepository barRepository = ref.watch(barRepositoryProvider);
    if (!editablePrices && (formState.value == null || formState.value!.isEmpty)) {
      return emptyWidget ?? const SizedBox.shrink();
    }

    List<BeerPrice> prices = formState.value!;
    if (prices.isEmpty && editablePrices) {
      prices.add(BeerPrice());
    }
    return Column(
      children: [
        for (BeerPrice price in prices)
          Row(
            mainAxisAlignment: editablePrices ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: editablePrices
                ? [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          right: 5,
                        ),
                        child: DropdownButtonFormField<String>(
                          value: price.barUuid,
                          isExpanded: true,
                          itemHeight: 56,
                          items: [
                            DropdownMenuItem(
                              value: null,
                              child: Text(
                                noBarFoundText,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            for (Bar bar in barRepository.objects)
                              DropdownMenuItem<String>(
                                value: bar.uuid,
                                child: Text(
                                  bar.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                          ],
                          onChanged: (value) {
                            price.barUuid = value;
                            formState.didChange(prices);
                          },
                        ),
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 5,
                        ),
                        child: TextFormField(
                          decoration: InputDecoration(hintText: context.getString('beerDialog.prices.hint')),
                          initialValue: price.price?.toIntIfPossible().toString(),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (value) {
                            price.price = double.tryParse(value);
                            formState._setValue(prices);
                          },
                          onEditingComplete: () => formState.didChange(prices),
                        ),
                      ),
                    ),
                  ]
                : [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Text(
                          price.barUuid == null || !barRepository.hasUuid(price.barUuid!) ? noBarFoundText : barRepository.findByUuid(price.barUuid!)!.name,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Text(price.price == null ? '?' : NumberFormat.simpleCurrency(locale: EzLocalization.of(context)?.locale.languageCode).format(price.price)),
                  ],
          ),
        if (editablePrices)
          LargeButton(
            padding: const EdgeInsets.only(top: 30),
            text: context.getString('beerDialog.prices.add'),
            onPressed: () => formState.didChange(
              prices
                ..add(
                  BeerPrice(
                    barUuid: null,
                    price: null,
                  ),
                ),
            ),
          )
      ],
    );
  }
}
