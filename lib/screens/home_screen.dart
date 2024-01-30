import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ArCoreController arCoreController;

  @override
  void dispose() {
    arCoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Example AR"),
      ),
      body: ArCoreView(
        enableTapRecognizer: true,
        onArCoreViewCreated: _onArCoreViewCreated,
      ),
    );
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;
    arCoreController?.onNodeTap = (name) => onTapHandler(name);
    arCoreController?.onPlaneTap = _handleOnPlaneTap;
  }

  void _handleOnPlaneTap(List<ArCoreHitTestResult> hits) {
    final hit = hits.first;
    _addToucano(hit);
  }

  void _addToucano(ArCoreHitTestResult plane)async  {
    final ByteData textureBytes = await rootBundle.load('assets/topolino.jpg');
    final material = ArCoreMaterial(
      color: Colors.red,
      textureBytes: textureBytes.buffer.asUint8List(),
    );
    final cylindre = ArCoreCylinder(
      materials: [material],

      radius: 0.5,
      height: 0.3,
    );
    final node = ArCoreNode(
      shape: cylindre,

      position: plane.pose.translation,
      rotation: plane.pose.rotation,
    );
    // final toucanNode = ArCoreReferenceNode(
    //   name: "Damaged Helmet",
    //   objectUrl:
    //       "https://github.com/KhronosGroup/glTF-Sample-Models/raw/master/2.0/Duck/glTF/Duck.gltf",
    //   position: plane.pose.translation,
    //   rotation: plane.pose.rotation,
    // );

    arCoreController?.addArCoreNodeWithAnchor(node);
  }

  void onTapHandler(String name) {
    print("Flutter: onNodeTap");
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: Row(
          children: <Widget>[
            Text('Remove ?'),
            IconButton(
                icon: Icon(
                  Icons.delete,
                ),
                onPressed: () {
                  arCoreController?.removeNode(nodeName: name);
                  Navigator.pop(context);
                })
          ],
        ),
      ),
    );
  }
}
