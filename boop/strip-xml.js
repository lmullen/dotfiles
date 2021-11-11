/**
  {
    "api":1,
    "name":"Strip XML/HTML",
    "description":"Strips XML/HTML from text",
    "author":"Lincoln Mullen <lincoln@lincolnmullen.com>",
    "icon":"watch",
    "tags":"XML,HTML"
  }
**/

function removeTags(str) {
  if ((str===null) || (str===''))
    return '';
  else
    str = str.toString();
    return str.replace( /(<([^>]+)>)/ig, '');
}


function main(state) {
  state.text = removeTags(state.text);
}
