def topological_sort(dag):
  if len(dag) == 1:
    head, refs = dag.popitem()
    return [head]

  head, headless_dag = get_head(dag)
  remove_head_refs(head, headless_dag)
  return [head] + topological_sort(headless_dag)


def get_head(dag):
  for node, refs in dag.iteritems():
    if len(refs) == 0:
      dag.pop(node)
      return node, dag
  return -1, dag


def remove_head_refs(head, dag):
  for node, refs in dag.iteritems():
    refs.discard(head)


a, b, c, d, e, f = range(6)
dag = {
  a: {},
  b: {a},
  c: {b},
  d: {b, c},
  e: {d},
  f: {a, b, d, e}
}
print topological_sort(dag)
