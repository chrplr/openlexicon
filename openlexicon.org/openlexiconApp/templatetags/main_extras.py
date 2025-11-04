from django import template

register = template.Library()

@register.filter
@register.simple_tag
def get_name(obj):
    if isinstance(obj, str):
        return obj
    return obj.name

@register.filter
@register.simple_tag
def get_id(obj):
    if isinstance(obj, str):
        return obj
    return obj.id
