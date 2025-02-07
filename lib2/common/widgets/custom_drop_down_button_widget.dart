import 'package:flutter/material.dart';
import '../../util/styles.dart';
import '../../util/dimensions.dart';

class CustomDropDownButtonWidget extends StatefulWidget {
  final String value;
  final List<String> itemList;
  final Function(String? value) onChanged;
  const CustomDropDownButtonWidget({
    Key? key,
    required this.value,
    required this.itemList,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<CustomDropDownButtonWidget> createState() => _CustomDropDownButtonWidgetState();
}

class _CustomDropDownButtonWidgetState extends State<CustomDropDownButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSizeSmall),
        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
      ),
      child: DropdownButton<String>(
        value: widget.value,
        icon: const Icon(Icons.keyboard_arrow_down),
        style: TextStyle(color: Theme.of(context).hintColor),
        underline: const SizedBox(),
        onChanged: (String? value)=>  widget.onChanged(value),
        items: widget.itemList.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(value: value, child: Text(value,
            style: rubikRegular.copyWith(fontSize: Dimensions.fontSizeDefault),));
        }).toList(),
        isExpanded: true,
      ),
    );
  }
}
