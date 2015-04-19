/***************************************************************************
 *                                  _   _ ____  _
 *  Project                     ___| | | |  _ \| |
 *                             / __| | | | |_) | |
 *                            | (__| |_| |  _ <| |___
 *                             \___|\___/|_| \_\_____|
 *
 * Copyright (C) 1998 - 2012, Daniel Stenberg, <daniel@haxx.se>, et al.
 *
 * This software is licensed as described in the file COPYING, which
 * you should have received as part of this distribution. The terms
 * are also available at http://curl.haxx.se/docs/copyright.html.
 *
 * You may opt to use, copy, modify, merge, publish, distribute and/or sell
 * copies of the Software, and permit persons to whom the Software is
 * furnished to do so, under the terms of the COPYING file.
 *
 * This software is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY
 * KIND, either express or implied.
 *
 ***************************************************************************/

#define CURL_STATICLIB
#define USE_SSLEAY
#define USE_OPENSSL

#ifdef _DEBUG
#	pragma comment(lib, "libcurld.lib")
#	pragma comment(lib, "ssleay32.lib")
#	pragma comment(lib, "libeay32.lib")
#	pragma comment(lib, "ws2_32.lib")
#	pragma comment(lib, "wldap32.lib")
#else
#	pragma comment(lib, "libcurl.lib")
#	pragma comment(lib, "ssleay32.lib")
#	pragma comment(lib, "libeay32.lib")
#	pragma comment(lib, "ws2_32.lib")
#	pragma comment(lib, "wldap32.lib")
#endif // _DEBUG

#include <cassert> 
#include <iostream> 
#include <string>
#include <curl/curl.h>

#include <stdio.h>
#include <curl/curl.h>

#define SKIP_PEER_VERIFICATION
#define SKIP_HOSTNAME_VERIFICATION

int main(void)
{
  CURL *curl;
  CURLcode res;

  curl_global_init(CURL_GLOBAL_DEFAULT);

  curl = curl_easy_init();
  if(curl)
  {
    curl_easy_setopt(curl, CURLOPT_URL, "https://127.0.0.1/");

#ifdef SKIP_PEER_VERIFICATION
    /*
     * If you want to connect to a site who isn't using a certificate that is
     * signed by one of the certs in the CA bundle you have, you can skip the
     * verification of the server's certificate. This makes the connection
     * A LOT LESS SECURE.
     *
     * If you have a CA cert for the server stored someplace else than in the
     * default bundle, then the CURLOPT_CAPATH option might come handy for
     * you.
     */
    curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);
#endif

#ifdef SKIP_HOSTNAME_VERIFICATION
    /*
     * If the site you're connecting to uses a different host name that what
     * they have mentioned in their server certificate's commonName (or
     * subjectAltName) fields, libcurl will refuse to connect. You can skip
     * this check, but this will make the connection less secure.
     */
    curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, 0L);
#endif

    /* Perform the request, res will get the return code */
    res = curl_easy_perform(curl);
    /* Check for errors */
    if(res != CURLE_OK)
      fprintf(stderr, "curl_easy_perform() failed: %s\n",
              curl_easy_strerror(res));

    /* always cleanup */
    curl_easy_cleanup(curl);
  }

  curl_global_cleanup();

  char cc = 0;
  std::cin >> cc;

  return 0;
}