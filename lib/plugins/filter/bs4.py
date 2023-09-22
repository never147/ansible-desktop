from __future__ import absolute_import, division, print_function

__metaclass__ = type

from ansible.errors import AnsibleError, AnsibleFilterError

try:
    from bs4 import BeautifulSoup

    HAS_LIB = True
except ImportError(BeautifulSoup):
    HAS_LIB = False


def bs4_find(data, name, attrs=None):
    """Query data using BeautifulSoup

    Example:
    - debug: msg="{{ html_data | bs4_find('table', {'title': 'bar'}) }}"
    """
    # if not HAS_LIB:
    #     raise AnsibleError('You need to install "bs4" prior to running '
    #                        'bs4_find filter')

    try:
        soup = BeautifulSoup(data, "html.parser")
        return soup.find(name, attrs)
    except Exception as e:
        raise AnsibleFilterError(
            "Error in soup.find in bs4_find filter " "plugin:\n%s" % e
        )


def bs4_text(element):
    if not HAS_LIB:
        raise AnsibleError(
            'You need to install "bs4" prior to running ' "bs4_find filter"
        )

    try:
        return element.text
    except Exception as e:
        raise AnsibleFilterError(
            "Error in element.text in bs4_text filter " "plugin:\n%s" % e
        )


def bs4_attr(element, attr):
    if not HAS_LIB:
        raise AnsibleError(
            'You need to install "bs4" prior to running ' "bs4_find filter"
        )

    try:
        return element.get(attr)
    except Exception as e:
        raise AnsibleFilterError(
            "Error in element.get in bs4_attr filter " "plugin:\n%s" % e
        )


class FilterModule(object):
    """Query filter"""

    @staticmethod
    def filters():
        return {"bs4_find": bs4_find, "bs4_text": bs4_text, "bs4_attr": bs4_attr}
