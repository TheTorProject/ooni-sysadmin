{% extends 'iptables.filter.part' %}
{% block svc %}
# postgresql
-A INPUT -s {{ lookup('dig', 'registry.proteus.ooni.io/A') }}/32 -p tcp -m tcp --dport 5432 -j ACCEPT
-A INPUT -s {{ lookup('dig', 'events.proteus.ooni.io/A') }}/32 -p tcp -m tcp --dport 5432 -j ACCEPT
-A INPUT -s {{ lookup('dig', 'datacollector.infra.ooni.io/A') }}/32 -p tcp -m tcp --dport 5432 -j ACCEPT
{% endblock %}
