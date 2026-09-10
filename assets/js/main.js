/* The burger: tell assistive tech whether the menu is open, keep the covered page out of reach
   while it is, and let Escape close it. The shared script toggles the class; this runs after. */
(function () {
    var burger = document.querySelector('.gh-burger');
    if (!burger) return;
    var behind = document.querySelectorAll('.site-content, .gh-foot');
    function sync() {
        var open = document.body.classList.contains('is-head-open');
        burger.setAttribute('aria-expanded', open);
        document.body.style.overflow = open ? 'hidden' : '';
        behind.forEach(function (el) { el.inert = open; });
    }
    burger.addEventListener('click', sync);
    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape' && document.body.classList.contains('is-head-open')) burger.click();
    });
})();

/* The subscribe form hides its row on success, which drops focus; move it to the message. */
(function () {
    document.querySelectorAll('.subscribe').forEach(function (form) {
        new MutationObserver(function () {
            if (form.classList.contains('success')) form.querySelector('.subscribe-success').focus();
        }).observe(form, {attributes: true, attributeFilter: ['class']});
    });
})();
