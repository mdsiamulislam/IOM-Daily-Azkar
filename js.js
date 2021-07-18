var count = (function () {

    let counter = 0;
    return function () {
        return counter +=1;
    }
    
})();

function displayCount() {
    document.getElementById('cariar').innerHTML= count()
}

function reset() {
    location.reload();

}