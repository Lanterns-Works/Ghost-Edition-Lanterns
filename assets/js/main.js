/* The subscribe form hides its row on success, which drops focus; move it to the message. */
(function () {
    document.querySelectorAll('.subscribe').forEach(function (form) {
        new MutationObserver(function () {
            if (form.classList.contains('success')) form.querySelector('.subscribe-success').focus();
        }).observe(form, {attributes: true, attributeFilter: ['class']});
    });
})();
