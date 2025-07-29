import 'package:beerstory/i18n/translations.g.dart';
import 'package:beerstory/model/bar/bar.dart';
import 'package:beerstory/model/bar/repository.dart';
import 'package:beerstory/model/beer/beer.dart';
import 'package:beerstory/model/beer/price/price.dart';
import 'package:beerstory/model/beer/price/repository.dart';
import 'package:beerstory/model/beer/repository.dart';
import 'package:beerstory/model/repository.dart';
import 'package:beerstory/spacing.dart';
import 'package:beerstory/utils/utils.dart';
import 'package:beerstory/widgets/centered_circular_progress_indicator.dart';
import 'package:beerstory/widgets/editors/form_dialog.dart';
import 'package:beerstory/widgets/empty.dart';
import 'package:beerstory/widgets/error.dart';
import 'package:beerstory/widgets/waiting_overlay.dart';
import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart';

/// Allows to display the prices of a beer.
class _BeerPricesDetailsWidget extends PricesDetailsWidget<Bar, BarRepository> {
  /// The beer UUID.
  final String beerUuid;

  /// Creates a new beer prices details widget instance.
  const _BeerPricesDetailsWidget({
    super.scrollController,
    required this.beerUuid,
  }) : super._();

  @override
  String buildTitle(BeerPrice beerPrice, List<Bar> availableObjects) {
    NumberFormat numberFormat = NumberFormat.simpleCurrency(locale: translations.$meta.locale.languageCode);
    return numberFormat.format(beerPrice.amount);
  }

  @override
  String? buildSubtitle(BeerPrice beerPrice, List<Bar> availableObjects) {
    Bar? bar = availableObjects.firstWhereOrNull((bar) => bar.uuid == beerPrice.barUuid);
    return bar?.name;
  }

  @override
  Iterable<BeerPrice> filterList(List<BeerPrice> list) => list.where((price) => price.beerUuid == beerUuid);

  @override
  BeerPrice createNewBeerPrice(List<Bar> availableObjects) => BeerPrice(
    beerUuid: beerUuid,
    barUuid: availableObjects.firstOrNull?.uuid,
  );

  @override
  AsyncNotifierProvider<BarRepository, List<Bar>> get repositoryProvider => barRepositoryProvider;
}

/// Allows to display the prices of a bar.
class _BarPricesDetailsWidget extends PricesDetailsWidget<Beer, BeerRepository> {
  /// The bar UUID.
  final String barUuid;

  /// Creates a new bar prices details widget instance.
  const _BarPricesDetailsWidget({
    super.scrollController,
    required this.barUuid,
  }) : super._();

  @override
  String buildTitle(BeerPrice beerPrice, List<Beer> availableObjects) {
    Beer? beer = availableObjects.firstWhereOrNull((beer) => beer.uuid == beerPrice.beerUuid);
    return beer?.name ?? 'Beer';
  }

  @override
  String? buildSubtitle(BeerPrice beerPrice, List<Beer> availableObjects) {
    NumberFormat numberFormat = NumberFormat.simpleCurrency(locale: translations.$meta.locale.languageCode);
    return numberFormat.format(beerPrice.amount);
  }

  @override
  Iterable<BeerPrice> filterList(List<BeerPrice> list) => list.where((price) => price.barUuid == barUuid);

  @override
  BeerPrice createNewBeerPrice(List<Beer> availableObjects) => BeerPrice(
    barUuid: barUuid,
    beerUuid: availableObjects.first.uuid,
  );

  @override
  AsyncNotifierProvider<BeerRepository, List<Beer>> get repositoryProvider => beerRepositoryProvider;
}

/// Allows to display the beer prices details.
abstract class PricesDetailsWidget<T extends HasName, R extends Repository<T>> extends ConsumerWidget {
  /// The scroll controller.
  final ScrollController? scrollController;

  /// Creates a new prices details widget instance.
  const PricesDetailsWidget._({
    super.key,
    this.scrollController,
  });

  /// Creates a new prices details widget instance.
  static PricesDetailsWidget create<T extends HasName>({
    required ScrollController? scrollController,
    required String objectUuid,
  }) {
    if (isSubtype<T, Beer>()) {
      return _BeerPricesDetailsWidget(
        scrollController: scrollController,
        beerUuid: objectUuid,
      );
    } else if (isSubtype<T, Bar>()) {
      return _BarPricesDetailsWidget(
        scrollController: scrollController,
        barUuid: objectUuid,
      );
    }
    throw ArgumentError('$T is not Beer or Bar.');
  }

  /// The corresponding repository provider.
  AsyncNotifierProvider<R, List<T>> get repositoryProvider;

  /// Filters the [list] to extract only required prices.
  Iterable<BeerPrice> filterList(List<BeerPrice> list);

  /// Builds the title of the price.
  String buildTitle(BeerPrice beerPrice, List<T> availableObjects);

  /// Builds the subtitle of the price.
  String? buildSubtitle(BeerPrice beerPrice, List<T> availableObjects) => null;

  /// Creates a new beer price.
  BeerPrice createNewBeerPrice(List<T> availableObjects);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<List<T>> availableObjects = ref.watch(repositoryProvider);
    AsyncValue<List<BeerPrice>> objects = ref.watch(beerPriceRepositoryProvider);
    if (availableObjects.isLoading || objects.isLoading) {
      return const CenteredCircularProgressIndicator();
    }

    if (availableObjects.hasError || objects.hasError) {
      return ErrorWidget(
        error: availableObjects.error ?? objects.error!,
        stackTrace: availableObjects.stackTrace ?? objects.stackTrace,
        onRetryPressed: () {
          ref.refresh(beerPriceRepositoryProvider);
          ref.refresh(repositoryProvider);
        },
      );
    }

    Iterable<BeerPrice> beerPrices = filterList(objects.value!);
    List<Widget> children = [];
    if (objects.value!.isEmpty) {
      children.add(
        const Center(
          child: EmptyWidget(text: 'Pas de prix ajouté.'),
        ),
      );
    } else {
      for (BeerPrice beerPrice in beerPrices) {
        String title = buildTitle(beerPrice, availableObjects.value!);
        String? subtitle = buildSubtitle(beerPrice, availableObjects.value!);
        children.add(
          FTile(
            title: Text(title),
            subtitle: subtitle == null ? null : Text(subtitle),
            onPress: () async {
              BeerPrice? editedPrice = await _BeerPriceEditorDialog.show<T>(
                context: context,
                beerPrice: beerPrice,
                availableObjects: availableObjects.value!,
              );
              if (editedPrice == null || !context.mounted) {
                return;
              }
              if (editedPrice is _DeletedBeerPrice) {
                await deleteBeerPrice(context, ref, editedPrice);
              } else if (editedPrice != beerPrice) {
                await editBeerPrice(context, ref, editedPrice);
              }
            },
          ),
        );
      }
    }
    return ListView(
      controller: scrollController,
      children: [
        for (Widget child in children)
          Padding(
            padding: const EdgeInsets.only(top: kSpace),
            child: child,
          ),
        Padding(
          padding: const EdgeInsets.only(top: kSpace),
          child: IntrinsicWidth(
            child: FButton(
              style: FButtonStyle.primary(),
              child: const Text('Ajouter un prix'),
              onPress: () async {
                BeerPrice? addedPrice = await _BeerPriceEditorDialog.show<T>(
                  context: context,
                  beerPrice: createNewBeerPrice(availableObjects.value!),
                  availableObjects: availableObjects.value!,
                  showDeleteButton: false,
                );
                if (addedPrice != null && context.mounted) {
                  await addBeerPrice(context, ref, addedPrice);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Adds a given beer price and shows a waiting overlay.
  Future<void> addBeerPrice(BuildContext context, WidgetRef ref, BeerPrice addedBeerPrice) async {
    await showWaitingOverlay(
      context,
      future: ref.read(beerPriceRepositoryProvider.notifier).add(addedBeerPrice),
    );
  }

  /// Edits a given beer price and shows a waiting overlay.
  Future<void> editBeerPrice(BuildContext context, WidgetRef ref, BeerPrice editedBeerPrice) async {
    await showWaitingOverlay(
      context,
      future: ref.read(beerPriceRepositoryProvider.notifier).change(editedBeerPrice),
    );
  }

  /// Deletes a given beer price and shows a waiting overlay.
  Future<void> deleteBeerPrice(BuildContext context, WidgetRef ref, BeerPrice editedBeerPrice) async {
    await showWaitingOverlay(
      context,
      future: ref.read(beerPriceRepositoryProvider.notifier).remove(editedBeerPrice),
    );
  }
}

/// Allows to edit a single beer price.
class _BeerPriceEditorDialog<T extends HasName> extends FormDialog<BeerPrice> {
  /// The available objects to pick.
  final List<T> availableObjects;

  /// Whether to show the delete button.
  final bool showDeleteButton;

  /// The beer price editor internal constructor.
  const _BeerPriceEditorDialog._({
    required super.object,
    super.animation,
    super.style,
    this.availableObjects = const [],
    required this.showDeleteButton,
  });

  @override
  _BeerPriceEditorDialogState<T> createState() => _BeerPriceEditorDialogState<T>();

  /// Shows a new beer price editor.
  static Future<BeerPrice?> show<T extends HasName>({
    required BuildContext context,
    required BeerPrice beerPrice,
    required List<T> availableObjects,
    bool showDeleteButton = true,
  }) => showFDialog<BeerPrice>(
    context: context,
    builder: (context, style, animation) => _BeerPriceEditorDialog<T>._(
      object: beerPrice,
      style: style.call,
      animation: animation,
      availableObjects: availableObjects,
      showDeleteButton: showDeleteButton,
    ),
  );
}

/// The beer price editor dialog state.
class _BeerPriceEditorDialogState<T extends HasName> extends FormDialogState<BeerPrice, _BeerPriceEditorDialog<T>> {
  /// The current beer price.
  late BeerPrice beerPrice = widget.object;

  @override
  List<Widget> createChildren(BuildContext context) => [
    Padding(
      padding: const EdgeInsets.only(bottom: kSpace),
      child: FSelectMenuTile<T?>(
        title: Text(title),
        label: Text(label),
        detailsBuilder: (_, values, _) => values.firstOrNull?.name == null ? const SizedBox.shrink() : Text(values.firstOrNull!.name),
        initialValue: uuidInitialValue,
        menu: [
          for (T object in widget.availableObjects)
            FSelectTile<T?>(
              title: Text(object.name),
              value: object,
            ),
          if (isSubtype<T, Beer>())
            FSelectTile<T?>(
              title: const Text('Bar non spécifié'),
              value: null,
            ),
        ],
        onSaved: (value) {
          T? object = value?.firstOrNull;
          if (value is Beer) {
            beerPrice = beerPrice.copyWith(beerUuid: object?.uuid);
          } else if (value is Bar) {
            beerPrice = beerPrice.overwriteBar(barUuid: object?.uuid);
          }
        },
      ),
    ),
    Padding(
      padding: const EdgeInsets.only(bottom: kSpace * 2),
      child: FTextFormField(
        label: const Text('Prix'),
        hint: 'Prix de la bière',
        initialText: beerPrice.amount.toString(),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onSaved: (value) => beerPrice = beerPrice.copyWith(amount: double.tryParse(value ?? '')),
        validator: emptyStringValidator,
      ),
    ),
    if (widget.showDeleteButton)
      Padding(
        padding: const EdgeInsets.only(bottom: kSpace * 2),
        child: FButton(
          style: FButtonStyle.destructive(),
          child: const Text('Supprimer'),
          onPress: () {
            beerPrice = _DeletedBeerPrice(beerPrice);
            saveAndPop(context);
          },
        ),
      ),
  ];

  /// The UUID initial value.
  T? get uuidInitialValue {
    String? uuid = isSubtype<T, Beer>() ? beerPrice.beerUuid : beerPrice.barUuid;
    return uuid == null ? null : widget.availableObjects.findByUuid(uuid);
  }

  /// The title of the price tile.
  String get title => isSubtype<T, Beer>() ? 'Beer' : 'Bar';

  /// The label of the price tile.
  String get label => isSubtype<T, Beer>() ? 'What beer did you see that price for ?' : 'Where did you see that price ?';

  @override
  BeerPrice? onSaved() => beerPrice;
}

/// Represents a deleted beer price.
class _DeletedBeerPrice extends BeerPrice {
  /// Creates a new deleted beer price instance.
  _DeletedBeerPrice._({
    super.uuid,
    required super.beerUuid,
    required super.barUuid,
    super.amount,
  });

  /// Creates a new deleted beer price instance.
  _DeletedBeerPrice(BeerPrice beerPrice)
    : this._(
        uuid: beerPrice.uuid,
        beerUuid: beerPrice.beerUuid,
        barUuid: beerPrice.barUuid,
        amount: beerPrice.amount,
      );

  @override
  bool operator ==(Object other) => other is _DeletedBeerPrice ? super == other : identical(this, other);

  @override
  int get hashCode => super.hashCode;

  @override
  _DeletedBeerPrice copyWith({
    String? uuid,
    String? beerUuid,
    String? barUuid,
    double? amount,
  }) => _DeletedBeerPrice._(
    uuid: uuid ?? this.uuid,
    beerUuid: beerUuid ?? this.beerUuid,
    barUuid: barUuid ?? this.barUuid,
    amount: amount ?? this.amount,
  );

  @override
  _DeletedBeerPrice overwriteBar({String? barUuid}) => _DeletedBeerPrice._(
    uuid: uuid,
    beerUuid: beerUuid,
    barUuid: barUuid,
    amount: amount,
  );
}
