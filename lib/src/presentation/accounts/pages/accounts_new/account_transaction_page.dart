import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../main.dart';
import '../../../../core/common.dart';
import '../../../../data/category/data_sources/category_local_data_source.dart';
import '../../../../domain/category/entities/category.dart';
import '../../../summary/widgets/expense_item_widget.dart';
import '../../../widgets/paisa_empty_widget.dart';
import '../../bloc/accounts_bloc.dart';

class AccountTransactionPage extends StatelessWidget {
  AccountTransactionPage({
    Key? key,
    required this.accountId,
  }) : super(key: key);

  final String accountId;
  final LocalCategoryManagerDataSource categoryLocalDataSource = getIt.get();
  late final AccountsBloc accountsBloc = getIt.get()
    ..add(FetchAccountFromIdEvent(accountId));

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: accountsBloc,
      builder: (context, state) {
        if (state is AccountSuccessState) {
          final account = state.account;
          return Scaffold(
            appBar: AppBar(),
            body: Builder(
              builder: (context) {
                final expenses = accountsBloc
                    .fetchExpenseFromAccountId(int.parse(accountId));
                if (expenses.isEmpty) {
                  return EmptyWidget(
                    icon: Icons.credit_card,
                    title: context.loc.noTransactionLabel,
                    description: context.loc.emptyAccountDescriptionLabel,
                  );
                } else {
                  return ListView(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 0,
                        ),
                        title: Text(
                          context.loc.transactionHistoryLabel,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: expenses.length,
                        itemBuilder: (context, index) {
                          final Category category = accountsBloc
                              .fetchCategoryFromId(expenses[index].categoryId)!
                              .toEntity();
                          return ExpenseItemWidget(
                            expense: expenses[index],
                            account: account,
                            category: category,
                          );
                        },
                      ),
                    ],
                  );
                }
              },
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
