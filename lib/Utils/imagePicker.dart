// ignore_for_file: unnecessary_getters_setters, file_names

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:eClassify/Utils/Extensions/extensions.dart';
import 'package:eClassify/Utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'helper_utils.dart';

class PickImage {
  final ImagePicker _picker = ImagePicker();
  final StreamController _imageStreamController = StreamController.broadcast();

  Stream get imageStream => _imageStreamController.stream;

  StreamSink get _sink => _imageStreamController.sink;
  StreamSubscription? subscription;
  File? _pickedFile;

  File? get pickedFile => _pickedFile;

  set pickedFile(File? pickedFile) {
    _pickedFile = pickedFile;
  }

/*  Future<void> pick({
    ImageSource? source,
    bool? pickMultiple,
    int? imageLimit,
    int? maxLength,
    required BuildContext context,
  }) async {
    final _picker = ImagePicker();

    if (pickMultiple == false || pickMultiple == null) {
      try {
        final pickedFile = await _picker.pickImage(
          source: source ?? ImageSource.gallery,
        );

        if (pickedFile == null) {
          _sink.add({"error": "No image selected", "file": null});
          return;
        }

        File file = File(pickedFile.path);
        if (await file.length() > Constant.maxSizeInBytes) {
          file = await HelperUtils.compressImageFile(file);
        }

        _sink.add({"error": "", "file": file});
      } catch (error) {
        _sink.add({"error": error.toString(), "file": null});
      }
    } else {
      try {
        final List<XFile> list = await _picker.pickMultiImage();

        if (list.isEmpty) {
          _sink.add({"error": "No images selected", "file": null});
          return;
        }

        if (imageLimit != null &&
            maxLength != null &&
            (list.length + maxLength) > imageLimit) {
          HelperUtils.showSnackBarMessage(
              context, "max5ImagesAllowed".translate(context));
        } else {
          List<File> tempListFile = [];
          for (final image in list) {
            File myImage = File(image.path);
            if (await myImage.length() > Constant.maxSizeInBytes) {
              myImage = await HelperUtils.compressImageFile(myImage);
            }
            tempListFile.add(myImage);
          }

          _sink.add({"error": "", "file": tempListFile});
        }
      } catch (error) {
        _sink.add({"error": error.toString(), "file": null});
      }
    }
  }*/

  pick(
      {ImageSource? source,
      bool? pickMultiple,
      int? imageLimit,
      int? maxLength,
      required BuildContext context}) async {
    if (pickMultiple == false || pickMultiple == null) {
      await _picker
          .pickImage(
        source: source ?? ImageSource.gallery,
      )
          .then((XFile? pickedFile) async {
        File file = File(pickedFile!.path);

        /* int threeMB = 3000000;
        if (await file.length() >= threeMB) {
          File? file2 = (await HelperUtils.compressImageFile(file));
          file = file2;
        }*/

        if (await file.length() > Constant.maxSizeInBytes) {
          file = await HelperUtils.compressImageFile(file);
        }
//adding map to stream
        _sink.add({
          "error": "",
          "file": file,
        });
      }).catchError((error) {
        _sink.add({
          "error": error,
          "file": null,
        });
      });
    } else {
      List<XFile> list = await _picker.pickMultiImage(
        imageQuality: Constant.uploadImageQuality,
      );

      if (imageLimit != null &&
          maxLength != null &&
          (list.length + maxLength) > imageLimit) {
        HelperUtils.showSnackBarMessage(
            context, "max5ImagesAllowed".translate(context));
      } else {
        // int threeMB = 3000000;

        Iterable<Future<File>> result = list.map((image) async {
          File myImage = File(image.path);
          int length = await image.length();
          if (await myImage.length() > Constant.maxSizeInBytes) {
            myImage = await HelperUtils.compressImageFile(myImage);
          }
          /*if (length >= threeMB) {
            File? file2 =
                (await HelperUtils.compressImageFile(File(image.path)));
            myImage = file2;
            // var i = await myImage.length();
          }*/
          else {
            myImage = File(image.path);
          }
          return myImage;
        });
        List<File> templistFile = [];
        await for (Future<File> futureFile in Stream.fromIterable(result)) {
          File file = await futureFile;
          templistFile.add(file);
        }

        _sink.add({
          "error": "",
          "file": templistFile,
        });
      }
      // templistFile.clear();
    }
  }

  /// This widget will listen changes in ui, it is wrapper around Stream builder
  Widget listenChangesInUI(
    dynamic Function(
      BuildContext context,
      dynamic image,
    ) ondata,
  ) {
    return StreamBuilder(
        stream: imageStream,
        builder: ((context, AsyncSnapshot snapshot) {
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.active) {
            if (snapshot.data['file'] is File) {
              pickedFile = snapshot.data["file"];
            }

            return ondata.call(
              context,
              snapshot.data["file"],
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return ondata.call(
              context,
              null,
            );
          }
          return ondata.call(
            context,
            null,
          );
        }));
  }

  void listener(void Function(dynamic)? onData) {
    subscription = imageStream.listen((data) {

      if ((subscription?.isPaused == false)) {

        onData?.call(data['file']);
      }
    });
  }

  void pauseSubscription() {
    subscription?.pause();
  }

  void resumeSubscription() {
    subscription?.resume();
  }

  void clearImage() {
    pickedFile = null;
    _sink.add(null);
  }

  void dispose() {
    if (!_imageStreamController.isClosed) {
      _imageStreamController.close();
    }
  }
}

enum PickImageStatus { initial, waiting, done, error }
