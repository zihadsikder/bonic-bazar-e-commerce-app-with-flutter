import 'package:eClassify/data/cubits/Report/item_report_cubit.dart';
import 'package:eClassify/Utils/Extensions/extensions.dart';
import 'package:eClassify/Utils/helper_utils.dart';
import 'package:eClassify/Utils/responsiveSize.dart';
import 'package:eClassify/Utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/cubits/Report/fetch_item_report_reason_list.dart';
import '../../../data/model/ReportProperty/reason_model.dart';
import '../../../exports/main_export.dart';

class ReportItemScreen extends StatefulWidget {
  final int itemId;

  const ReportItemScreen({super.key, required this.itemId});

  @override
  State<ReportItemScreen> createState() => _ReportItemScreenState();
}

class _ReportItemScreenState extends State<ReportItemScreen> {
  List<ReportReason>? reasons = [];
  late int selectedId;
  final TextEditingController _reportmessageController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  void initState() {
    reasons = context.read<FetchItemReportReasonsListCubit>().getList() ?? [];

    if (reasons?.isEmpty ?? true) {
      selectedId = -10;
    } else {
      selectedId = reasons!.first.id;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double bottomPadding = (MediaQuery.of(context).viewInsets.bottom - 50);
    bool isBottomPaddingNagative = bottomPadding.isNegative;
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("reportItem".translate(context)).size(context.font.larger),
              const SizedBox(
                height: 15,
              ),
              ListView.separated(
                shrinkWrap: true,
                itemCount: reasons?.length ?? 0,
                physics: const BouncingScrollPhysics(),
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 10);
                },
                itemBuilder: (context, index) {
                  return InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      if (selectedId == reasons![index].id) {
                        // selectedId = -10;
                      } else {
                        selectedId = reasons![index].id;
                      }
                      setState(() {});
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.color.primaryColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: selectedId == reasons?[index].id
                                ? context.color.territoryColor
                                : context.color.borderColor,
                            width: 1.5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child:
                            Text(reasons?[index].reason.firstUpperCase() ?? "")
                                .color(selectedId == reasons?[index].id
                                    ? context.color.territoryColor
                                    : context.color.textColorDark),
                      ),
                    ),
                  );
                },
              ),
              if (selectedId.isNegative)
                Padding(
                  padding: EdgeInsets.only(
                      bottom: isBottomPaddingNagative ? 0 : bottomPadding,
                      left: 0,
                      right: 0),
                  child: TextFormField(
                    maxLines: null,
                    controller: _reportmessageController,
                    cursorColor: context.color.territoryColor,
                    validator: (val) {

                      if (val == null || val.isEmpty) {
                        return "addReportReason".translate(context);
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                        hintText: "writeReasonHere".translate(context),
                        focusColor: context.color.territoryColor,
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: context.color.territoryColor))),
                  ),
                ),
              const SizedBox(
                height: 14,
              ),
              BlocConsumer<ItemReportCubit, ItemReportState>(
                  listener: (context, state) {

                if (state is ItemReportInSuccess) {
                  HelperUtils.showSnackBarMessage(
                      context, state.responseMessage,
                      messageDuration: 3);
                  Future.delayed(Duration(seconds: 2), () {
                    Navigator.pop(context);
                  });
                }
                if (state is ItemReportFailure) {
                  HelperUtils.showSnackBarMessage(
                      context, state.error.toString(),
                      messageDuration: 3);
                  Future.delayed(Duration(seconds: 2), () {
                    Navigator.pop(context);
                  });
                }
              }, builder: (context, state) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MaterialButton(
                        height: 40,
                        minWidth: 104.rw(context),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: BorderSide(
                              color: context.color.borderColor,
                              width: 1.5,
                            )),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("cancelLbl".translate(context))
                            .color(context.color.territoryColor),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      MaterialButton(
                        height: 40,
                        minWidth: 104.rw(context),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            30,
                          ),
                        ),
                        color: context.color.territoryColor,
                        onPressed: () async {

                          if (Constant
                              .isDemoModeOn) {
                            HelperUtils.showSnackBarMessage(
                                context,
                                "thisActionNotValidDemo"
                                    .translate(
                                    context));
                            return;
                          }
                          if (selectedId.isNegative) {

                            if (_formKey.currentState!.validate()) {
                              context.read<ItemReportCubit>().report(
                                  item_id: widget.itemId,
                                  reason_id: selectedId,
                                  message: _reportmessageController.text);
                            }
                          } else {
                            context.read<ItemReportCubit>().report(
                                item_id: widget.itemId, reason_id: selectedId);
                          }
                        },
                        child: (state is ItemReportInProgress)
                            ? UiUtils.progress(width: 24, height: 24)
                            : Text("report".translate(context))
                                .color(context.color.buttonColor),
                      ),
                    ],
                  ),
                );
              })
            ],
          ),
        ),
      ),
    );
  }
}
