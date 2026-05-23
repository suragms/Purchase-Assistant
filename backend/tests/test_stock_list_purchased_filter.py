"""Stock list period parsing and purchased-in-period gate."""

from datetime import date

from app.routers.stock import _parse_period_dates


def test_parse_period_dates_all_time_window():
    ps, pe = _parse_period_dates("1970-01-01", "2099-12-31")
    assert ps == date(1970, 1, 1)
    assert pe == date(2099, 12, 31)
