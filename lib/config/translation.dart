import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en': {
          'login': 'Login',
          'valid_email': 'Enter a valid email.',
          'email': 'Email',
          'password': 'Password',
          'password_requirement': 'Password must be at least 8 characters.',
          'confirm_pass': 'Confirm Password',
          'pass_not_match': "Passwords do not match",
          'password_must_have_one_uppercase':
              'Password must contain at least one uppercase',
          'password_must_have_one_lowercase':
              'Password must contain at least one lowercase',
          'password_must_have_one_number':
              'Password must contain at least one number',
          'password_must_have_one_special_character':
              'Password must contain at least one special character',
          'create_account': 'Create Account',
          'first_name_requirement': 'First name must be at least 2 characters.',
          'first_name': 'First name',
          'last_name_requirement': 'Last name must be at least 2 characters.',
          'last_name': 'Last name',
          'phone_number': 'Phone number',
          'invalid_phone': 'Invalid Phone Number',
          'no_trips_yet': 'No trips yet',
          'no_trips_description':
              'You haven\'t taken any trips yet. Let\'s get moving!',
          'no_routes_yet': 'No routes yet',
          'no_routes_found':
              'No routes found on the server, please check back later.',
          'refresh': 'Refresh',
          'subscribe_route': 'Subscribe to Route',
          'unnamed_stop': 'Unnamed Stop',
          'km_from_previous': 'km from previous',
          'my_wallet': 'My Wallet',
          'help_support': 'Help and Support',
          'about_us': 'About Us',
          'terms_conditions': 'Terms and Conditions',
          'privacy_policy': 'Privacy Policy',
          'logout': 'Log out',
          'no_account': 'Don\'t have an account? ',
          'have_account': 'Already have an account? ',
          'sign_up_here': 'Sign Up Here',
          'log_in_here': 'Log In Here',
          'no_internet': 'No Internet Connection',
          'no_internet_description':
              'It seems that your internet connection is turned off. Please turn it on and try again.',
          'retry': 'Retry',
          'check_connection':
              'Please check your internet connection and try again.',
          'internal_server_error': 'Internal Server Error',
          'internal_server_error_desc':
              'The server encountered an error and could not complete your request.',
          'service_unavailable': 'Service Unavailable',
          'service_unavailable_desc':
              'The service is temporarily unavailable. Please try again later.',
          'not_found': 'Not Found',
          'not_found_desc':
              'The requested resource was not found on the server.',
          'gateway_timeout': 'Gateway Timeout',
          'gateway_timeout_desc':
              'The gateway did not receive a timely response from the upstream server.',
          'unauthorized': 'Unauthorized',
          'unauthorized_desc':
              'You are not authorized to access this resource.',
          'forbidden': 'Forbidden',
          'forbidden_desc':
              'You do not have permission to access this resource.',
          'too_many_requests': 'Too Many Requests',
          'too_many_requests_desc':
              'You have sent too many requests in a given amount of time.',
          'error': 'Error',
          'unknown_error': 'Unknown Error',
          'unexpected_error': 'An unexpected error occurred, please try later',
        },
        'am': {
          'login': 'ግባ',
          'valid_email': 'ትክክለኛ ኢሜል አስገባ።',
          'email': 'ኢሜል',
          'password': 'የይለፍ ቃል',
          'password_requirement': 'የይለፍ ቃሉ ቢያንስ 8 ፊደል መሆን አለበት።',
          'confirm_pass': 'የይለፍ ቃል ያረጋግጡ',
          'pass_not_match': "የይለፍ ቃሎቹ አይመሳሰሉም",
          'password_must_have_one_uppercase':
              'የይለፍ ቃሉ ቢያንስ አንድ ካፒታል ፊደል ሊኖረዉ ይገባል',
          'password_must_have_one_lowercase':
              'የይለፍ ቃሉ ቢያንስ አንድ ካፒታል ያልሆነ ፊደል ሊኖረዉ ይገባል',
          'password_must_have_one_number': 'የይለፍ ቃሉ ቢያንስ አንድ ቁጥር ሊኖረዉ ይገባል',
          'password_must_have_one_special_character':
              'የይለፍ ቃሉ ቢያንስ አንድ ልዩ ፊደል ሊኖረዉ ይገባል',
          'create_account': 'መለያ ፍጠር',
          'first_name_requirement': 'የመጀመሪያ ስም ቢያንስ 2 ፊደል መሆን አለበት።',
          'first_name': 'የመጀመሪያ ስም',
          'last_name_requirement': 'የመጨረሻ ስም ቢያንስ 2 ፊደል መሆን አለበት።',
          'last_name': 'የመጨረሻ ስም',
          'phone_number': 'ስልክ ቁጥር',
          'invalid_phone': 'የተሳሳተ ስልክ ቁጥር',
          'no_trips_yet': 'ጉዞ የለም',
          'no_trips_description': 'እስካሁን ምንም ጉዞ አልወሰድህም። እንጀምር!',
          'no_routes_yet': 'የተመዘገቡ መንገዶች የሉም',
          'no_routes_found': 'ሰርቨር ላይ የተመዘገበ መንገድ አልተገኘም። እባክዎ ቆይተዉ በድጋሜ ይሞክሩ።',
          'refresh': 'በድጋሜ ይሞክሩ',
          'subscribe_route': 'በዚህ መንገድ ላይ ይመዝገቡ',
          'unnamed_stop': 'ያልተሰየመ መደብ',
          'km_from_previous': 'ኪ.ሜ ከቀደመው ',
          'my_wallet': 'የእኔ ዋሌት',
          'help_support': 'እርዳታ እና ድጋፍ',
          'about_us': 'ስለ እኛ',
          'terms_conditions': 'ውሎች እና መመሪያዎች',
          'privacy_policy': 'የግላዊነት ፖሊሲ',
          'logout': 'ውጣ',
          'no_account': 'መለያ የለዎትም? ',
          'have_account': 'አካውንት አለዎት? ',
          'sign_up_here': 'እዚህ ይመዝገቡ',
          'log_in_here': 'እዚህ ይግቡ',
          'no_internet': 'ኢንተርኔት አልተገኘም',
          'no_internet_description': 'ኢንተርኔትዎ ተጠፍቷል። እባክዎ ያብሩና ደግመው ይሞክሩ።',
          'retry': 'በድጋሜ ይሞክሩ',
          'check_connection': 'እባክዎ ኢንተርኔት ግንኙነትዎን ያረጋግጡ እና ደግመው ይሞክሩ።',
          'internal_server_error': 'የሰርቨር ስህተት',
          'internal_server_error_desc':
              'ሰርቨሩ ላይ ስህተት ተፈጥሯል እና ጥያቄዎን ማጠናቀቅ አልቻለም።',
          'service_unavailable': 'አገልግሎቱ አይገኝም',
          'service_unavailable_desc':
              'አገልግሎቱ ለጊዜዉ እየተሰጠ አይደለም። እባክዎ በኋላ ደግመው ይሞክሩ።',
          'not_found': 'አልተገኘም',
          'not_found_desc': 'የተጠየቀው መረጃ በሰርቨሩ ላይ አልተገኘም።',
          'gateway_timeout': 'የተሰጠዎት ጊዜ አልቋል',
          'gateway_timeout_desc': 'ሰርቨሩ የተገባ ምላሽ በጊዜ አልሰጠም።',
          'unauthorized': 'ፈቃድ የለዎትም',
          'unauthorized_desc': 'ይህን መረጃ ለማግኘት ፈቃድ የለዎትም።',
          'forbidden': 'አይችሉም',
          'forbidden_desc': 'ይህን መረጃ ማግኘት ክልክል ነዉ።',
          'too_many_requests': 'ብዙ ጥያቄዎች',
          'too_many_requests_desc': 'በትንሽ ጊዜ ውስጥ ብዙ ጥያቄዎች ልከዋል።',
          'error': 'ስህተት',
          'unknown_error': 'ያልታወቀ ስህተት',
          'unexpected_error': 'ያልተጠበቀ ስህተት ተፈጥሯል፣ እባክዎ በኋላ ይሞክሩ',
        },
      };
}
