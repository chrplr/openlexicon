function collapse_menu(menu) {
    $(menu).next().collapse("hide");
    $(menu).prop('aria-expanded', 'false');
    $(menu).find('.submenu-icon').find('i').removeClass('fa-sort-up');
    $(menu).find('.submenu-icon').find('i').addClass('fa-sort-down');
}

function expand_menu(menu) {
    $(menu).next().collapse("show");
    $(menu).prop('aria-expanded', 'true');
    $(menu).find('.submenu-icon').find('i').removeClass('fa-sort-down');
    $(menu).find('.submenu-icon').find('i').addClass('fa-sort-up');
}

function menu_is_open(menu) {
    return $(menu).prop('aria-expanded') === 'true';
}

function close_menu(menu) {
    collapse_menu(menu);
    localStorage.setItem($(menu).prop('id'), 'collapsed');
}

function open_menu(menu) {
    expand_menu(menu);
    localStorage.setItem($(menu).prop('id'), 'expanded');
    // closing brother menus
    // $(menu).parent().children('.nav-menu-text:not(#' + $(menu).attr('id') +')').each(function() {
    //     close_menu($(this));
    // });
}

function menu_click(event) {
    let menu = $(event.target);
    if(!menu.hasClass('nav-menu-text')) {
        // if clicked on the checkbox or tooltip
        if (menu.hasClass("database-checkbox") || menu.parents('.tooltipable').length > 0){
            return;
        }
        menu = $(menu.parents('.nav-menu-text'));
    }
    if(menu.next().hasClass('collapsing')) {
        // if the menu is currently collapsing
        return false;
    }
    if(menu_is_open(menu)) {
        close_menu(menu);
    } else {
        open_menu(menu);
    }
    return false;
}


// id: id of the element that will contain the tooltip
// def: content of the tooltip
// content: text that triggers the tooltip
// if content is null, puts a questionmark.
function make_popover(id, def, label=false, content=null, link=null) {
    $('[data-item="'+id+'"]').each(function(){
        var tag;
        if (link != null) {
            if (def != "") {
                def += "<br>";
            }
            def += "<a class='float-right' href='" + link + "'> " + gettext("Edit") +" </a>";
        }
        tag = document.createElement("a");
        tag.setAttribute("data-html", "true");
        tag.setAttribute("class", "tooltipable");
        tag.setAttribute("data-toggle", "popover");
        tag.setAttribute("data-placement", "auto");
        tag.setAttribute("data-trigger", "hover");
        tag.setAttribute("data-content", def);
        tag.setAttribute("tabindex", "0");
        tag.setAttribute("role", "button");

        $(tag).popover({
            container: 'body', // put popover inside body to avoid other elements with greater z-index hiding it
        });

        if (content == null) {
            var symbol = document.createElement("i");
            symbol.setAttribute("class", "fa fa-question-circle");
            tag.appendChild(symbol);
            tag.setAttribute("style", "margin-left: auto;");
        } else {
            tag.append(content);
        }

        $(tag).insertBefore($(this).children('.submenu-icon'));
    });

}
