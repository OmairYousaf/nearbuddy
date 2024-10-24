import 'package:flutter/material.dart';

import '../../../../../constants/colors.dart';

class SearchBarWidget extends StatelessWidget {
  Function(String) onSubmitted;
  TextEditingController searchController;
  bool searchFlag;
  Function onIconClose;
   SearchBarWidget({Key? key,required this.onSubmitted,required this.searchController,required this.searchFlag,required this.onIconClose}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(5.0),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 1),
            color: Color(0xFFE8E8E8),
            blurRadius: 20,
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
            Expanded(
              child: TextField(
                style: TextStyle(
                    color: kBlackLight,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
                textInputAction: TextInputAction.search,
                onSubmitted: (val) {
                  if (val.isNotEmpty) {
                    FocusScope.of(context).requestFocus(FocusNode());
                    onSubmitted(val);
                  }
                },
                enabled: true,
                onChanged: null,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                  hintText: "Search Here",
                  hintStyle: TextStyle(
                    color: kGreyDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  disabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                ),
                controller: searchController,
              ),
            ),
            (searchFlag)
                ? IconButton(
                onPressed: (){
                  onIconClose();
                },
                icon: Icon(
                  Icons.close,
                  color: kGrey,
                ))
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
