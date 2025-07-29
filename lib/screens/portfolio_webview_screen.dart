// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// class PortfolioWebViewScreen extends StatefulWidget {
//   const PortfolioWebViewScreen({super.key});

//   @override
//   State<PortfolioWebViewScreen> createState() => _PortfolioWebViewScreenState();
// }

// class _PortfolioWebViewScreenState extends State<PortfolioWebViewScreen>
//     with TickerProviderStateMixin {
//   late WebViewController controller;
//   bool isLoading = true;
//   bool hasError = false;
//   String errorMessage = '';
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();
    
//     // Initialize animation controller
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     );
    
//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeInOut,
//     ));

//     // Initialize WebView controller
//     controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onProgress: (int progress) {
//             // Update loading progress
//             if (progress == 100) {
//               setState(() {
//                 isLoading = false;
//               });
//               _animationController.forward();
//             }
//           },
//           onPageStarted: (String url) {
//             setState(() {
//               isLoading = true;
//               hasError = false;
//             });
//           },
//           onPageFinished: (String url) {
//             setState(() {
//               isLoading = false;
//             });
//             _animationController.forward();
//           },
//           onWebResourceError: (WebResourceError error) {
//             setState(() {
//               isLoading = false;
//               hasError = true;
//               errorMessage = error.description;
//             });
//           },
//         ),
//       )
//       ..loadRequest(Uri.parse('https://dhananjayrpatil.web.app'));
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: _buildAppBar(),
//       body: _buildBody(),
//       floatingActionButton: _buildFloatingActionButton(),
//     );
//   }

//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       elevation: 0,
//       backgroundColor: Colors.transparent,
//       flexibleSpace: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.blue, Colors.purple, Colors.pink],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//       ),
//       title: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: const Icon(
//               Icons.web,
//               color: Colors.white,
//               size: 24,
//             ),
//           ),
//           const SizedBox(width: 12),
//           const Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   'Portfolio Website',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   'Dhananjay Patil',
//                   style: TextStyle(
//                     color: Colors.white70,
//                     fontSize: 14,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       actions: [
//         if (!isLoading && !hasError)
//           IconButton(
//             onPressed: () => controller.reload(),
//             icon: const Icon(Icons.refresh, color: Colors.white),
//             tooltip: 'Refresh',
//           ),
//         PopupMenuButton<String>(
//           icon: const Icon(Icons.more_vert, color: Colors.white),
//           onSelected: (value) {
//             switch (value) {
//               case 'refresh':
//                 controller.reload();
//                 break;
//               case 'home':
//                 controller.loadRequest(Uri.parse('https://dhananjayrpatil.web.app'));
//                 break;
//               case 'github':
//                 controller.loadRequest(Uri.parse('https://github.com/dhananjay7781'));
//                 break;
//               case 'linkedin':
//                 controller.loadRequest(Uri.parse('https://www.linkedin.com/in/dhananjay7/'));
//                 break;
//             }
//           },
//           itemBuilder: (BuildContext context) => [
//             const PopupMenuItem(
//               value: 'refresh',
//               child: Row(
//                 children: [
//                   Icon(Icons.refresh, color: Colors.blue),
//                   SizedBox(width: 8),
//                   Text('Refresh'),
//                 ],
//               ),
//             ),
//             const PopupMenuItem(
//               value: 'home',
//               child: Row(
//                 children: [
//                   Icon(Icons.home, color: Colors.orange),
//                   SizedBox(width: 8),
//                   Text('Portfolio Home'),
//                 ],
//               ),
//             ),
//             const PopupMenuItem(
//               value: 'github',
//               child: Row(
//                 children: [
//                   Icon(Icons.code, color: Colors.black87),
//                   SizedBox(width: 8),
//                   Text('GitHub Profile'),
//                 ],
//               ),
//             ),
//             const PopupMenuItem(
//               value: 'linkedin',
//               child: Row(
//                 children: [
//                   Icon(Icons.business, color: Colors.blue),
//                   SizedBox(width: 8),
//                   Text('LinkedIn Profile'),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildBody() {
//     if (hasError) {
//       return _buildErrorView();
//     }

//     return Stack(
//       children: [
//         if (!isLoading)
//           FadeTransition(
//             opacity: _fadeAnimation,
//             child: WebViewWidget(controller: controller),
//           ),
//         if (isLoading) _buildLoadingView(),
//       ],
//     );
//   }

//   Widget _buildLoadingView() {
//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.blue, Colors.purple, Colors.pink],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//       ),
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(
//                   color: Colors.white.withOpacity(0.2),
//                   width: 1,
//                 ),
//               ),
//               child: Column(
//                 children: [
//                   Container(
//                     width: 80,
//                     height: 80,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       border: Border.all(
//                         color: Colors.white,
//                         width: 3,
//                       ),
//                     ),
//                     child: ClipOval(
//                       child: Image.network(
//                         'https://avatars.githubusercontent.com/u/89823947?u=f58c183de1a5354536e8f3134c35998c0c2fe26c&v=4',
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) {
//                           return const Icon(
//                             Icons.person,
//                             size: 40,
//                             color: Colors.white,
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   const CircularProgressIndicator(
//                     valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                     strokeWidth: 3,
//                   ),
//                   const SizedBox(height: 20),
//                   const Text(
//                     'Loading Portfolio...',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   const Text(
//                     'dhananjayrpatil.web.app',
//                     style: TextStyle(
//                       color: Colors.white70,
//                       fontSize: 14,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildErrorView() {
//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.red, Colors.pink],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//       ),
//       child: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(30),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(
//                     color: Colors.white.withOpacity(0.2),
//                     width: 1,
//                   ),
//                 ),
//                 child: Column(
//                   children: [
//                     const Icon(
//                       Icons.error_outline,
//                       size: 80,
//                       color: Colors.white,
//                     ),
//                     const SizedBox(height: 20),
//                     const Text(
//                       'Oops! Something went wrong',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 10),
//                     Text(
//                       'Unable to load the portfolio website',
//                       style: TextStyle(
//                         color: Colors.white.withOpacity(0.8),
//                         fontSize: 16,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 8),
//                     if (errorMessage.isNotEmpty)
//                       Text(
//                         errorMessage,
//                         style: TextStyle(
//                           color: Colors.white.withOpacity(0.7),
//                           fontSize: 14,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     const SizedBox(height: 30),
//                     ElevatedButton.icon(
//                       onPressed: () {
//                         setState(() {
//                           hasError = false;
//                           isLoading = true;
//                         });
//                         controller.reload();
//                       },
//                       icon: const Icon(Icons.refresh, color: Colors.white),
//                       label: const Text(
//                         'Try Again',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.white.withOpacity(0.2),
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 30,
//                           vertical: 15,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(30),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFloatingActionButton() {
//     if (isLoading || hasError) return const SizedBox.shrink();
    
//     return FloatingActionButton.extended(
//       onPressed: () => controller.loadRequest(Uri.parse('https://dhananjayrpatil.web.app')),
//       backgroundColor: Colors.blue,
//       foregroundColor: Colors.white,
//       icon: const Icon(Icons.home),
//       label: const Text('Portfolio Home'),
//       elevation: 8,
//     );
//   }
// }
