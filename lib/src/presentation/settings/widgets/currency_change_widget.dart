import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../../../../main.dart';
import '../../../app/routes.dart';
import '../../../core/common.dart';
import '../../../core/enum/box_types.dart';

class CurrencyChangeWidget extends StatelessWidget {
  const CurrencyChangeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Box<dynamic> settings =
        getIt.get<Box<dynamic>>(instanceName: BoxType.settings.name);
    final String customSymbol =
        settings.get(userCustomCurrencyKey, defaultValue: '');
    final String currentSymbol = NumberFormat.compactSimpleCurrency(
                locale: settings.get(userLanguageKey))
            .currencyName ??
        '';
    return ListTile(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(
                      context.loc.currencySignLabel,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      context.pushNamed(
                        splashName,
                        extra: {
                          'force_change_currency': true,
                        },
                      );
                    },
                    title: Text(context.loc.selectCurrencyLabel),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      _showCustomCurrencySymbol(context);
                    },
                    title: Text(context.loc.customSymbolLabel),
                  )
                ],
              ),
            );
          },
        );
      },
      title: Text(context.loc.currencySignLabel),
      subtitle: Text(
        customSymbol.isNotEmpty ? customSymbol : currentSymbol,
      ),
    );
  }
}

void _showCustomCurrencySymbol(BuildContext context) {
  final Box<dynamic> settings =
      getIt.get<Box<dynamic>>(instanceName: BoxType.settings.name);
  showModalBottomSheet(
    constraints: BoxConstraints(
      maxWidth:
          MediaQuery.of(context).size.width >= 700 ? 700 : double.infinity,
    ),
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
    ),
    context: context,
    builder: (context) {
      return CustomCurrencySymbol(
        settings: settings,
        currentSymbol: settings.get(userCustomCurrencyKey, defaultValue: '\$'),
      );
    },
  );
}

class CustomCurrencySymbol extends StatefulWidget {
  const CustomCurrencySymbol({
    super.key,
    required this.settings,
    required this.currentSymbol,
  });

  final Box<dynamic> settings;
  final String currentSymbol;

  @override
  State<CustomCurrencySymbol> createState() => _CustomCurrencySymbolState();
}

class _CustomCurrencySymbolState extends State<CustomCurrencySymbol> {
  final format = NumberFormat("#,##,##0.00", "en_US");
  final TextEditingController editingController = TextEditingController();
  late String symbol = widget.currentSymbol;
  bool symbolLeftOrRight = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                context.loc.customSymbolLabel,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ListTile(
                    horizontalTitleGap: 0,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Sample: ${symbolLeftOrRight ? symbol : ''}${format.format(1000000)}${symbolLeftOrRight ? '' : symbol}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  TextFormField(
                    maxLines: 1,
                    decoration: InputDecoration(
                      filled: false,
                      counterText: "",
                      hintText: context.loc.enterSymbolLabel,
                    ),
                    controller: editingController,
                    keyboardType: TextInputType.text,
                    onChanged: (value) {
                      setState(() {
                        symbol = value;
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            symbolLeftOrRight
                                ? context.loc.leftSymbolLabel
                                : context.loc.rightSymbolLabel,
                          ),
                        ),
                        Switch(
                          value: symbolLeftOrRight,
                          onChanged: (value) {
                            setState(() {
                              symbolLeftOrRight = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(context.loc.cancelLabel),
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onPressed: () {
                          widget.settings
                              .delete(userCustomCurrencyKey)
                              .then((value) => Navigator.pop(context));
                        },
                        child: Text(
                          context.loc.deleteLabel,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onPressed: () {
                          if (editingController.text.isNotEmpty) {
                            widget.settings.put(
                                userCustomCurrencyKey, editingController.text);
                            Navigator.pop(context);
                          }
                        },
                        child: Text(context.loc.doneLabel),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
