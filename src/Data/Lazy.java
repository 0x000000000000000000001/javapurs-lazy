    // The JavaScript implementation memoizes the thunk; a cell and a pending slot
    // keep the same behavior.
    public static Object defer = (java.util.function.Function<Object, Object>) (thunk) -> {
        Object[] value = new Object[]{ null };
        Object[] pending = new Object[]{ thunk };
        return (java.util.function.Supplier<Object>) () -> {
            if (pending[0] != null) {
                // The JavaScript thunk is a (Unit -> a) function.
                value[0] = ((java.util.function.Function<Object, Object>) pending[0]).apply(null);
                pending[0] = null;
            }
            return value[0];
        };
    };

    public static Object force = (java.util.function.Function<Object, Object>) (lazy) ->
        ((java.util.function.Supplier<Object>) lazy).get();
