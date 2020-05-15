采集数据的时候经常碰到一些JSON数据的Key值不是字符串，这些数据在JavaScript的上下文中是可以解析的，但在Python中，没有该部分数据的上下文，无法采用json.loads(JSON)的形式导入。在网上搜集来一些方法以便日后使用。

方法一：
'''Python
def parse_js(expr):
    """
    解析非标准JSON的Javascript字符串，等同于json.loads(JSON str)
    :param expr:非标准JSON的Javascript字符串
    :return:Python字典
    """
    obj = eval(expr, type('Dummy', (dict,), dict(__getitem__=lambda s, n: n))())
    return obj
'''
方法二(推荐)

'''Python
def parse_js(expr):
    """
    解析非标准JSON的Javascript字符串，等同于json.loads(JSON str)
    :param expr:非标准JSON的Javascript字符串
    :return:Python字典
    """
    import ast
    m = ast.parse(expr)
    a = m.body[0]

    def parse(node):
        if isinstance(node, ast.Expr):
            return parse(node.value)
        elif isinstance(node, ast.Num):
            return node.n
        elif isinstance(node, ast.Str):
            return node.s
        elif isinstance(node, ast.Name):
            return node.id
        elif isinstance(node, ast.Dict):
            return dict(zip(map(parse, node.keys), map(parse, node.values)))
        elif isinstance(node, ast.List):
            return map(parse, node.elts)
        else:
            raise NotImplementedError(node.__class__)

    return parse(a)
'''

[出处](https://www.cnblogs.com/taceywong/p/5876621.html)
