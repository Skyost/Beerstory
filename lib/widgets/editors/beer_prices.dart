import 'package:beerstory/i18n/translations.g.dart';
import 'package:beerstory/model/bar/bar.dart';
import 'package:beerstory/model/beer/beer.dart';
import 'package:beerstory/model/beer/price/price.dart';
import 'package:beerstory/model/repository.dart';
import 'package:beerstory/utils/format.dart';
import 'package:beerstory/utils/utils.dart';
import 'package:beerstory/widgets/editors/form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// Allows to edit a single beer price.
class BeerPriceEditorDialog<T extends HasName> extends FormDialog<BeerPrice> {
  /// The available objects to pick.
  final List<T> availableObjects;

  /// Whether to show the delete button.
  final bool showDeleteButton;

  /// The beer price editor internal constructor.
  BeerPriceEditorDialog._({
    required super.object,
    super.animation,
    super.style,
    this.availableObjects = const [],
    required this.showDeleteButton,
  }) : assert(
         isSubtype<T, Beer>() || isSubtype<T, Bar>(),
         '$T must be a Beer or a Bar.',
       );

  @override
  FormDialogState<BeerPrice, BeerPriceEditorDialog<T>> createState() => _BeerPriceEditorDialogState<T>();

  /// Shows a new beer price editor.
  static Future<FormDialogResult<BeerPrice>> show<T extends HasName>({
    required BuildContext context,
    required BeerPrice beerPrice,
    required List<T> availableObjects,
    bool showDeleteButton = true,
  }) => FormDialog.show(
    context: context,
    object: beerPrice,
    builder:
        ({
          required BeerPrice object,
          FDialogStyle Function(FDialogStyle)? style,
          Animation<double>? animation,
        }) => BeerPriceEditorDialog<T>._(
          object: object,
          style: style,
          animation: animation,
          availableObjects: availableObjects,
          showDeleteButton: showDeleteButton,
        ),
  );
}

/// The beer price editor dialog state.
class _BeerPriceEditorDialogState<T extends HasName> extends FormDialogState<BeerPrice, BeerPriceEditorDialog<T>> {
  /// The current beer price.
  late BeerPrice beerPrice = widget.object;

  @override
  List<Widget> createChildren(BuildContext context) => [
    FSelectMenuTile<T?>(
      title: Text(title),
      label: Text(label),
      detailsBuilder: (_, values, _) => Text(
        values.firstOrNull == null ? translations.beerPrices.dialog.bar.unspecified : values.firstOrNull!.name,
      ),
      initialValue: uuidInitialValue,
      menu: [
        for (T object in widget.availableObjects)
          FSelectTile<T?>(
            title: Text(object.name),
            value: object,
          ),
        if (!isBeerType)
          FSelectTile<T?>(
            title: Text(translations.beerPrices.dialog.bar.unspecified),
            value: null,
          ),
      ],
      onSaved: (value) {
        T? object = value?.firstOrNull;
        if (isBeerType) {
          beerPrice = beerPrice.copyWith(
            beerUuid: object?.uuid,
          );
        } else {
          beerPrice = beerPrice.overwriteBar(
            barUuid: object?.uuid,
          );
        }
      },
    ),
    FTextFormField(
      label: Text(translations.beerPrices.dialog.price.title),
      hint: translations.beerPrices.dialog.price.label,
      initialText: NumberFormat.formatDouble(beerPrice.amount),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onSaved: (value) => beerPrice = beerPrice.copyWith(
        amount: NumberFormat.tryParseDouble(value),
      ),
      validator: (value) => numbersValidator(value, allowEmpty: false),
    ),
    if (widget.showDeleteButton)
      FButton(
        style: FButtonStyle.destructive(),
        child: Text(translations.beerPrices.dialog.delete),
        onPress: () {
          beerPrice = DeletedBeerPrice(beerPrice);
          saveAndPop(context);
        },
      ),
  ];

  /// The UUID initial value.
  T? get uuidInitialValue {
    String? uuid = isBeerType ? beerPrice.beerUuid : beerPrice.barUuid;
    return uuid == null ? null : widget.availableObjects.findByUuid(uuid);
  }

  /// Whether the current object is a beer.
  bool get isBeerType => isSubtype<T, Beer>();

  /// The title of the price tile.
  String get title => isBeerType ? translations.beerPrices.dialog.beer.title : translations.beerPrices.dialog.bar.title;

  /// The label of the price tile.
  String get label => isBeerType ? translations.beerPrices.dialog.beer.label : translations.beerPrices.dialog.bar.label;

  @override
  BeerPrice? onSaved() => beerPrice;
}

/// Represents a deleted beer price.
class DeletedBeerPrice extends BeerPrice {
  /// Creates a new deleted beer price instance.
  DeletedBeerPrice._({
    super.uuid,
    required super.beerUuid,
    required super.barUuid,
    super.amount,
  });

  /// Creates a new deleted beer price instance.
  DeletedBeerPrice(BeerPrice beerPrice)
    : this._(
        uuid: beerPrice.uuid,
        beerUuid: beerPrice.beerUuid,
        barUuid: beerPrice.barUuid,
        amount: beerPrice.amount,
      );

  @override
  bool operator ==(Object other) => other is DeletedBeerPrice ? super == other : identical(this, other);

  @override
  // ignore: unnecessary_overrides
  int get hashCode => super.hashCode;

  @override
  DeletedBeerPrice copyWith({
    String? uuid,
    String? beerUuid,
    String? barUuid,
    double? amount,
  }) => DeletedBeerPrice._(
    uuid: uuid ?? this.uuid,
    beerUuid: beerUuid ?? this.beerUuid,
    barUuid: barUuid ?? this.barUuid,
    amount: amount ?? this.amount,
  );

  @override
  DeletedBeerPrice overwriteBar({String? barUuid}) => DeletedBeerPrice._(
    uuid: uuid,
    beerUuid: beerUuid,
    barUuid: barUuid,
    amount: amount,
  );
}
