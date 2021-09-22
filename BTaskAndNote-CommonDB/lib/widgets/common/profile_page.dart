import 'package:flutter/material.dart';


class ProfilePageView extends StatelessWidget {
  const ProfilePageView(this.name, this.imagePath, this.emailID, this.phoneNumber,{Key? key}) : super(key: key);

  final String name;
  final String imagePath;
  final String emailID;
  final String phoneNumber;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
        ),
        body: Center(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.80,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      width: 100,
                      height: 100,
                      child: Image.asset(imagePath),
                    ),
                  ),
                  Row(
                    children: [
                      Text('Name :'),
                      Text('$name'),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Email ID: '),
                      Text('$emailID'),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Phone Number: '),
                      Text('$phoneNumber'),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Date Registered: '),
                      Text('${DateTime.now()}'),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
