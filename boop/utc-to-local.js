/**
  {
    "api":1,
    "name":"UTC timestamp to local time",
    "description":"Converts a UTC timestamp (2021-08-18T20:51:16Z) to local time",
    "author":"Lincoln Mullen <lincoln@lincolnmullen.com>",
    "icon":"watch",
    "tags":"time,utc,timestamp,log"
  }
**/

function main(state) {
  var localDate = new Date(state.text);
  state.text = localDate.toString();
}
