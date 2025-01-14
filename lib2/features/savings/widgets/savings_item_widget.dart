// // lib/features/savings/presentation/widgets/savings_item_widget.dart

// import 'package:flutter/material.dart';
// import 'package:six_cash/features/savings/domain/savings_model.dart';
// // import 'package:six_cash/features/savings/domain/models/savings_model.dart';
// import 'package:six_cash/util/dimensions.dart';

// class SavingsItemWidget extends StatelessWidget {
//   final SavingsModel savingsModel;
//   final VoidCallback? onTap;

//   const SavingsItemWidget({
//     Key? key,
//     required this.savingsModel,
//     this.onTap,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // Example UI layout for a single savings item
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
//         padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
//         decoration: BoxDecoration(
//           color: Theme.of(context).cardColor,
//           borderRadius: BorderRadius.circular(10),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.1),
//               blurRadius: 2,
//               offset: const Offset(0, 1),
//             )
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Account #${savingsModel.accountNumber ?? ''}',
//               style: Theme.of(context).textTheme.titleLarge,
//             ),
//             const SizedBox(height: Dimensions.paddingSizeSmall),
//             Text(
//               'Balance: ${savingsModel.balance?.toStringAsFixed(2) ?? '0.00'}',
//               style: Theme.of(context).textTheme.bodyLarge,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
