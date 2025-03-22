const BookmarkInsights = {
    mounted() {
        this.el.scrollTop = this.el.scrollHeight
        this.handleEvent("scroll_insights_to_bottom", () => {
            this.el.scrollTop = this.el.scrollHeight
        })
    }
};

export default BookmarkInsights;