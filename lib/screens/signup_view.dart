// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:second_app/core/common/snackbar/my_snackbar.dart';
// import 'package:second_app/feature/auth/domain/entity/auth_entity.dart';
// import 'package:second_app/feature/auth/presentation/view_model/auth_viewmodel.dart';

// class SignupView extends ConsumerStatefulWidget {
//   const SignupView({Key? key}) : super(key: key);

//   @override
//   ConsumerState<SignupView> createState() => _SignupViewState();
// }

// class _SignupViewState extends ConsumerState<SignupView> {
//   final fNameController = TextEditingController();
//   final lNameController = TextEditingController();
//   final emailController = TextEditingController();
//   final phoneNumberController = TextEditingController();
//   final passwordController = TextEditingController();
//   bool validateInputs() {
//     if (fNameController.text.isEmpty ||
//         lNameController.text.isEmpty ||
//         emailController.text.isEmpty ||
//         phoneNumberController.text.isEmpty ||
//         passwordController.text.isEmpty) {
//       showSnackBar(
//         message: 'Please fill in all fields.',
//         context: context,
//         color: Colors.red,
//       );
//       return false;
//     }
//     return true;
//   }

//   bool _passwordVisible = false;

//   @override
//   Widget build(BuildContext context) {
//     final authViewModel = ref.watch(authViewModelProvider.notifier);
//     return Scaffold(
//         backgroundColor: Theme.of(context).colorScheme.background,
//         body: SingleChildScrollView(
//           child: Container(
//             decoration: BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage(
//                     'assets/images/b3.png'), // Replace 'assets/background_image.png' with your image path
//                 fit: BoxFit.cover,
//               ),
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: <Widget>[
//                 Column(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.only(top: 60.0),
//                       child: Center(
//                         child: SizedBox(
//                             width: 200,
//                             height: 150,
//                             /*decoration: BoxDecoration(
//                           color: Colors.red,
//                           borderRadius: BorderRadius.circular(50.0)),*/
//                             child: Image.asset('assets/images/Second.png')),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(top: 10, bottom: 30),
//                       child: Text('SECOND',
//                           style: GoogleFonts.exo(
//                               textStyle:
//                                   Theme.of(context).textTheme.headlineLarge,
//                               fontSize: 24,
//                               color: Theme.of(context).colorScheme.primary)),
//                     ),
//                     Padding(
//                       //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
//                       padding: EdgeInsets.symmetric(horizontal: 15),
//                       child: TextFormField(
//                         controller: fNameController,
//                         decoration: InputDecoration(
//                           prefixIcon: Icon(Icons.person),
//                           border: OutlineInputBorder(),
//                           labelText: 'First Name',
//                           hintText: 'Enter first name',
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
//                       padding: EdgeInsets.only(
//                           left: 15.0, right: 15.0, top: 15, bottom: 0),
//                       child: TextFormField(
//                         controller: lNameController,
//                         decoration: InputDecoration(
//                           prefixIcon: Icon(Icons.person),
//                           border: OutlineInputBorder(),
//                           labelText: 'Last Name',
//                           hintText: 'Enter last name',
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
//                       padding: EdgeInsets.only(
//                           left: 15.0, right: 15.0, top: 15, bottom: 0),
//                       child: TextFormField(
//                         controller: emailController,
//                         decoration: InputDecoration(
//                           prefixIcon: Icon(Icons.email),
//                           border: OutlineInputBorder(),
//                           labelText: 'Email',
//                           hintText: 'Enter email',
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
//                       padding: EdgeInsets.only(
//                           left: 15.0, right: 15.0, top: 15, bottom: 0),
//                       child: TextFormField(
//                         controller: phoneNumberController,
//                         decoration: InputDecoration(
//                           prefixIcon: Icon(Icons.phone),
//                           border: OutlineInputBorder(),
//                           labelText: 'Phone no',
//                           hintText: 'Enter phone number',
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(
//                           left: 15.0, right: 15.0, top: 15, bottom: 0),
//                       //padding: EdgeInsets.symmetric(horizontal: 15),
//                       child: TextFormField(
//                         style: const TextStyle(color: Colors.black),
//                         controller: passwordController,
//                         obscureText: !_passwordVisible,
//                         decoration: InputDecoration(
//                             border: const OutlineInputBorder(),
//                             label: const Text("Password"),
//                             prefixIcon: const Icon(
//                               Icons.lock_open_outlined,
//                               size: 20,
//                             ),
//                             suffixIcon: IconButton(
//                               onPressed: () {
//                                 setState(() {
//                                   _passwordVisible = !_passwordVisible;
//                                 });
//                               },
//                               icon: Icon(
//                                 _passwordVisible
//                                     ? Icons.visibility
//                                     : Icons.visibility_off,
//                                 size: 20,
//                               ),
//                             )),
//                         validator: (value) {
//                           if (value == "") {
//                             return "password_cannot_be_empty";
//                           }
//                           return null;
//                         },
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(
//                           left: 15.0, right: 15.0, top: 15, bottom: 10),
//                       child: ElevatedButton(
//                         style: ButtonStyle(
//                           minimumSize: MaterialStateProperty.all<Size>(
//                               const Size(double.infinity, 48)),
//                           maximumSize: MaterialStateProperty.all<Size>(
//                               const Size(double.infinity, 48)),
//                           backgroundColor: MaterialStateProperty.all<Color>(
//                               const Color.fromARGB(255, 40, 40, 40)),
//                           // Replace 'red' with 'Colors.red'
//                         ),
//                         onPressed: () {
//                           if (validateInputs()) {
//                             authViewModel.registerUser(
//                               AuthEntity(
//                                 fName: fNameController.text,
//                                 lName: lNameController.text,
//                                 phoneNumber: phoneNumberController.text,
//                                 email: emailController.text,
//                                 password: passwordController.text,
//                               ),
//                             );
//                             showSnackBar(
//                               message: 'Registration successful!',
//                               context: context,
//                               color: Colors.green,
//                             );
//                           }
//                         },
//                         child: Text(
//                           "Sign Up",
//                           style: TextStyle(
//                             color: Colors.white70,
//                           ),
//                         ),
//                       ),
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.pushNamed(context, '/login');
//                       },
//                       child: Text.rich(
//                         TextSpan(
//                           children: [
//                             TextSpan(
//                               text: 'Already have account?  ',
//                               style: TextStyle(
//                                 color: Theme.of(context).colorScheme.secondary,
//                                 fontSize: 18,
//                                 fontFamily: 'Exo',
//                                 fontWeight: FontWeight.w400,
//                                 height: 0,
//                                 letterSpacing: 0.18,
//                               ),
//                             ),
//                             const TextSpan(
//                               text: 'Signin',
//                               style: TextStyle(
//                                 color: Color.fromRGBO(84, 175, 230, 1),
//                                 fontSize: 18,
//                                 fontFamily: 'Exo',
//                                 fontWeight: FontWeight.w400,
//                                 height: 0,
//                                 letterSpacing: 0.18,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ));
//   }
// }
