import 'package:flutter/material.dart';

import '../utils.dart';
import '../blocs/task_bloc.dart';
import '../models/user_model.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/big_text_input.dart';
import '../widgets/fractionally_screen_sized_box.dart';
import '../widgets/gradient_touchable_container.dart';
import '../widgets/priority_selector.dart';

class TaskScreen extends StatefulWidget {
  final bool isEdit;

  TaskScreen({
    this.isEdit = false,
  });

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final TaskBloc bloc = TaskBloc();
  String textFieldInitialValue;

  initState() {
    if (widget.isEdit) {
      bloc.populateWithCurrentTask();
    }
    textFieldInitialValue = bloc.textInitialValue;
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.isEdit ? 'Edit task' : 'Add task',
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 15.0, left: 20.0, right: 20.0),
            child: Column(
              children: <Widget>[
                BigTextInput(
                  initialValue: widget.isEdit ? textFieldInitialValue : '',
                  height: 95,
                  onChanged: bloc.changeTaskText,
                ),
                SizedBox(
                  height: 15,
                ),
                StreamBuilder(
                  stream: bloc.userModelStream,
                  builder: (BuildContext context,
                      AsyncSnapshot<UserModel> userSnapshot) {
                    List<String> events = [];

                    if (userSnapshot.hasData) {
                      events = userSnapshot.data.events;
                    }
                    return buildDropdownSection(events);
                  },
                ),
                SizedBox(
                  height: 15,
                ),
                buildPrioritySelectorSection(),
                SizedBox(
                  height: 20,
                ),
                StreamBuilder(
                  stream: bloc.submitEnabled,
                  builder: (context, submitSnap) {
                    return GradientTouchableContainer(
                      height: 40,
                      radius: 8,
                      isExpanded: true,
                      enabled: submitSnap.hasData,
                      onTap: () => onSubmit(context),
                      child: Text(
                        'Submit',
                        style: kSmallTextStyle,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDropdownSection(List<String> events) {
    return Row(
      children: <Widget>[
        Text(
          'Event',
          style: kBigTextStyle,
        ),
        Spacer(),
        FractionallyScreenSizedBox(
          widthFactor: 0.6,
          child: StreamBuilder(
            stream: bloc.eventName,
            builder: (BuildContext context, AsyncSnapshot<String> snap) {
              return CustomDropdownButton(
                isExpanded: true,
                value: snap.data,
                onChanged: bloc.changeEventName,
                hint: Text('Event'),
                items: events.map((String name) {
                  return CustomDropdownMenuItem(
                    value: name,
                    child: Text(
                      name,
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildPrioritySelectorSection() {
    return Row(
      children: <Widget>[
        Text(
          'Priority',
          style: kBigTextStyle,
        ),
        Spacer(),
        FractionallyScreenSizedBox(
          widthFactor: 0.6,
          child: PrioritySelector(
            onChage: bloc.setPriority,
          ),
        ),
      ],
    );
  }

  void onSubmit(BuildContext context) async {
    await bloc.submit(widget.isEdit);
    Navigator.of(context).pop();
  }

  void dispose() {
    bloc.dispose();
    super.dispose();
  }
}