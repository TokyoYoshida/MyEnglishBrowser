document.onmousemove= (function(e){

function getHitWord(hit_elem) {
var hit_word = '';
hit_elem = $(hit_elem);

//text contents of hit element
var text_nodes = hit_elem.contents().filter(function(){
return this.nodeType == Node.TEXT_NODE && this.nodeValue.match(/[a-zA-Z]{2,}/)
});

//bunch of text under cursor? break it into words
if (text_nodes.length > 0) {
var original_content = hit_elem.clone();

//wrap every word in every node in a dom element
text_nodes.replaceWith(function(i) {
return $(this).text().replace(/([a-zA-Z-]*)/g, "<word>$1</word>")
});

//get the exact word under cursor
var hit_word_elem = document.elementFromPoint(e.clientX, e.clientY);

if (hit_word_elem.nodeName != 'WORD') {
console.log("missed!");
}
else  {
hit_word = $(hit_word_elem).text();
console.log("got it: "+hit_word);
}

hit_elem.replaceWith(original_content);
}

return hit_word;
}

var hit_word = getHitWord(document.elementFromPoint(e.clientX, e.clientY));
console.log("OK"+hit_word+"]");
webkit.messageHandlers.callbackHandler.postMessage(hit_word);
})