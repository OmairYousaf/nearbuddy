import 'package:flutter/material.dart';

import '../../../../../constants/colors.dart';

class InterestSearchBarWidget extends StatelessWidget {
  String searchBoxTxt;
  TextEditingController searchController;
  Function onIconClose;
  Function(String) onSubmitted;
  InterestSearchBarWidget({Key? key,required this.searchBoxTxt,required this.onIconClose,required this.searchController,required this.onSubmitted}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(5.0),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 1),
            color: Colors.black12,
            blurRadius: 20,
          )
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(7.0),
              child: Text(
                searchBoxTxt,
                style: TextStyle(
                    color: kPrimaryColor, fontWeight: FontWeight.bold),
              ),
            ),
            const VerticalDivider(
              color: Colors.black12,
              thickness: 1,
              width: 5,
            ),
            const SizedBox(
              width: 5,
            ),
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
            IconButton(
                onPressed: (){
                  onIconClose();
                },
                icon: Icon(
                  Icons.close,
                  color: kGreyDark,
                )),
          ],
        ),
      ),
    );
  }
}
