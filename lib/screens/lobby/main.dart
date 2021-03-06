import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import './table_icon.dart';
import '../../common/common.dart';
import '../../theme/rally.dart';
import '../../provider/src.dart';
import 'anim_longclick_fab.dart';

class LobbyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Tooltip(
              message: AppLocalizations.of(context)!.lobby_report,
              child: MaterialButton(
                onPressed: () {
                  showBottomSheetMenu(context);
                },
                minWidth: MediaQuery.of(context).size.width / 2,
                shape: CustomShape(side: CustomShapeSide.left),
                child: Icon(Icons.menu),
              ),
            ),
            Tooltip(
              message: AppLocalizations.of(context)!.lobby_menuEdit,
              child: MaterialButton(
                onPressed: () => Navigator.pushNamed(context, '/edit-menu'),
                minWidth: MediaQuery.of(context).size.width / 2,
                shape: CustomShape(side: CustomShapeSide.right),
                child: Icon(Icons.menu_book_sharp),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () => _addTable(context),
        child: Icon(Icons.add),
        style: ElevatedButton.styleFrom(
          shape: CircleBorder(),
          padding: EdgeInsets.all(7),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      body: _InteractiveBody(),
    );
  }

  Future showBottomSheetMenu(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      // isScrollControlled combined with shrinkWrap for minimal height in bottom sheet
      isScrollControlled: true,
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: Text(
                AppLocalizations.of(context)?.lobby_report.toUpperCase() ?? 'HISTORY',
                textAlign: TextAlign.center,
              ),
              onTap: () => Navigator.pushNamed(context, '/history'),
            ),
            ListTile(
              title: Text(
                AppLocalizations.of(context)?.lobby_journal.toUpperCase() ?? 'EXPENSE JOURNAL',
                textAlign: TextAlign.center,
              ),
              onTap: () => Navigator.pushNamed(context, '/expense'),
            ),
          ],
        );
      },
    );
  }
}

/// Allow panning & dragging widgets inside...
class _InteractiveBody extends StatelessWidget {
  /// The key to container (1), must be passed into all DraggableWidget widgets in Stack
  final GlobalKey bgKey = GlobalKey();

  final TransformationController transformController = TransformationController();

  @override
  Widget build(BuildContext context) {
    final supplier = Provider.of<Supplier>(context, listen: true);
    return InteractiveViewer(
      maxScale: 2.0,
      transformationController: transformController,
      child: Stack(
        children: [
          // create a container (1) here to act as fixed background for the entire screen,
          // pan & scale effect from InteractiveViewer will actually interact with this container
          // thus also easily scale & pan all widgets inside the stack
          Container(key: bgKey),
          for (var model in supplier.tables)
            DraggableWidget(
              x: model.getOffset().x,
              y: model.getOffset().y,
              containerKey: bgKey,
              transformController: transformController,
              onDragEnd: (x, y) {
                model.setOffset(Coordinate(x, y), supplier);
              },
              key: ObjectKey(model),
              child: TableIcon(table: model),
            ),
        ],
      ),
    );
  }
}

// ******************************* //

void _addTable(BuildContext context) {
  var supplier = Provider.of<Supplier>(context, listen: false);
  supplier.addTable();
}
