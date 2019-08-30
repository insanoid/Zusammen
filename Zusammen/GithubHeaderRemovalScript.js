function removeItems() {
    var header = document.getElementsByClassName('position-relative js-header-wrapper')[0];
    var pageHead = document.getElementsByClassName('pagehead')[0];
    var signupPrompt = document.getElementsByClassName('signup-prompt-bg rounded-1')[0];
    var fileHeader = document.getElementsByClassName('d-flex flex-items-start flex-shrink-0 pb-3 flex-column flex-md-row')[0];
    var boxHeader1 = document.getElementsByClassName('Box Box--condensed d-flex flex-column flex-shrink-0')[0];
    var footer = document.getElementsByClassName('footer')[0];
    var boxHeader2 = document.getElementsByClassName('Box-header py-2 d-flex flex-column flex-shrink-0 flex-md-row flex-md-items-center')[0];

    header.parentNode.removeChild(header);
    pageHead.parentNode.removeChild(pageHead);
    signupPrompt.parentNode.removeChild(signupPrompt);
    fileHeader.parentNode.removeChild(fileHeader);
    boxHeader1.parentNode.removeChild(boxHeader1);
    footer.parentNode.removeChild(footer);
    boxHeader2.parentNode.removeChild(boxHeader2);
}
removeItems();
