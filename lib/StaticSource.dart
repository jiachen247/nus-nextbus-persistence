import 'dart:async';
import 'dart:convert';
import 'dart:io';

class StaticSource {
    final String BASE_URL = "https://jiachen247.github.io/nus-nextbus-data/";

    final String ISERVICES_FILE = "iservices.json";
    final String ESERVICES_FILE = "eservices.json";
    final String STOPS_FILE = "stops.json";
    final String FREQUENCY_FILE = "frequency.json";
    final String OPERATING_HOURS_FILE = "operating_hours.json";
    final String EROUTES_HOURS_FILE = "eroutes.json";

    var _httpClient = new HttpClient();

    Future<Stream> _get(String url)async {
      var request = await _httpClient.getUrl(Uri.parse("${url}"));
      request.headers.set("Accept", "applicatipn/json");

      var response = await request.close();

      if (response.statusCode == HttpStatus.OK) {
        Stream jsonStream = response.transform(UTF8.decoder);
        return jsonStream;
      }

    }

    Future<Map> getStaticIServices()async {
      Stream s = await _get(BASE_URL + ISERVICES_FILE);
      return JSON.decode(await s.join(""));
    }

    Future<Map> getStaticStops()async {
      Stream s = await _get(BASE_URL + STOPS_FILE);
      return JSON.decode(await s.join(""));
    }

    Future<Map> getStaticFrequency()async {
      Stream s = await _get(BASE_URL + FREQUENCY_FILE);
      return JSON.decode(await s.join(""));
    }

    Future<Map> getStaticOperatingHours()async {
      Stream s = await _get(BASE_URL + OPERATING_HOURS_FILE);
      return JSON.decode(await s.join(""));
    }

    Future<List> getStaticEServices()async {
        Stream s = await _get(BASE_URL + ESERVICES_FILE);
        return JSON.decode(await s.join(""));
    }

    Future<Map> getStaticERoutes()async {
        Stream s = await _get(BASE_URL + EROUTES_HOURS_FILE);
        return JSON.decode(await s.join(""));
    }

}